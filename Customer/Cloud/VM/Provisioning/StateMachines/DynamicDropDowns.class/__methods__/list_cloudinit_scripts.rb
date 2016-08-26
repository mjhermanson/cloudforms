# list_customization_templates.rb
#
# Author: Matt Hermanson
# License: GPL v3
#
# Description: Build Dialog of all RHEV tempalate guids based on the RBAC filters applied to a users group
#

dialog_hash = {}

customization_template = $evm.vmdb(:CustomizationTemplateCloudInit).name["rhel6-cloud-init"]
$evm.log(:info, "#{customization_template}")
