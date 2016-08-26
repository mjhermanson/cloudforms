###################################
#
# CFME Automate Method: BlueCat_AcquireIPAddress2
#
# Notes: This method uses a SOAP/XML call to BlueCat Proteus to reserve an IP Address and
#  and set the values in the miq_provision object.
# - Gem requirements: savon -v 2.1.0
# - Inputs: $evm.root['miq_provision']
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'BlueCat_AcquireIPAddress2'
    puts "#{@method} - #{message}"
  end

  # dump_root
  def dump_root()
    log(:info, "Root:<$evm.root> Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}
    log(:info, "Root:<$evm.root> End $evm.root.attributes")
    log(:info, "")
  end

  def call_BlueCat(prov)
    # Require Ruby Gem
    gem 'savon', '>=2.2.0'
    require "savon"
    require 'httpi'

    # Configure HTTPI gem
    HTTPI.log_level = :debug # changing the log level
    HTTPI.log       = false # diable HTTPI logging
    HTTPI.adapter   = :net_http # [:httpclient, :curb, :net_http]

    # Set servername below else use input from model
    servername = nil
    servername ||= $evm.object['servername']

    # Set username name below else use input from model
    username = nil
    username ||= $evm.object['username']

    # Set username name below else use input from model
    password = nil
    password ||= $evm.object.decrypt('password')

    # Set rootcontainer below else use input from model
    #rootcontainer = nil
    rootcontainer ||= $evm.object['rootcontainer']

    log(:info, "Servername: #{servername}")

    # Set gateway below else use input from model
    #gateway = nil
    gateway ||= $evm.object['gateway']

    # Set subnet mask below else use input from model
    #submask = nil
    submask ||= $evm.object['submask']
   
    # Set up Savon client
    client = Savon.client(wsdl: "https://#{servername}/Services/API?wsdl", ssl_verify_mode: :none)


    #log(:info, "Namespace:<#{client.wsdl.namespace}> Endpoint:<#{client.wsdl.endpoint}> Actions:<#{client.wsdl.soap_actions}>")

    # Log into BlueCat Proteus
    login_response = client.call(:login) do
        message username: username, password: password
    end

    log(:info, "login:<#{login_response.inspect}>")
    auth_cookies = login_response.http.cookies

    ip_to_remove = prov.options[:ip_addr]

    getIPobj = client.call(:get_ip4_address) do |ctx|
        ctx.cookies auth_cookies
        ctx.message container_id: container_id, address: ip_to_remove
    end
    getIPhash = getIPobj.to_hash[:get_ip4_address_response][:return]
    ipID = getIPhash[:id]
    log(:info, "IP ID: #{ipID}")

    client.call(:delete) do |ctx|
        ctx.cookies auth_cookies
        ctx.message object_id: ipID
    end

    
    # Log out of Proteus
    logout_response = client.call(:logout)
    log(:info, "logout: #{logout_response.inspect}")

  end

  log(:info, "CFME Automate Method Started")

  # dump all root attributes to the log
  dump_root
  # Get provisioning object
  prov = $evm.root['vm']
 # log(:info, "Provision:<#{prov.id}> Request:<#{prov.miq_provision_request.id}> Type:<#{prov.type}>")

  prov_tags = prov.get_tags
  log(:info, "Inspecting miq_provision tags:<#{prov_tags.inspect}>")

  #bluecat = prov_tags[:bluecat]

  #if bluecat.nil? || bluecat == 'false'
  #  log(:info, "Bluecat tag:<#{bluecat}>. skipping method")
  #  exit MIQ_OK
  #else
  call_BlueCat(prov)
  #end

  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit 0

  # Set Ruby rescue behavior
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit 1
end

