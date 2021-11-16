# This Script is run in the Shared Services account to create or
# delete VPC / Private Hosted Zone (PHZ) association authorisations.
# It's part of the process for sharing Interface VPC Endpoints with
# other VPCs.
#
# Note you can run this script multiple times with the same selections.
# The "create" operations are idempotent - will silently succeed with
# no effect should the authorisation already exist.
# Failed "delete" operations because there's no such authorisation are also
# harmless.
#
# Revision History: 
# - 28-May-20 Steve Kinsman - Inital release.
#!/usr/bin/python

import sys
import boto3


client = boto3.client('route53')
ec2client = boto3.client('ec2', 'ap-southeast-2')  # Hardcoded region for now




# Accepts a function object for a create or delete operation, and executes it
# on the specified Endpoint PHZ and VPC.
def run_auth_operation (authfunc, endpoint, vpcid):
    try:
        authfunc(
            HostedZoneId=endpoint,
            VPC={
                'VPCRegion': 'ap-southeast-2',
                'VPCId': vpcid
            }
        )
    except client.exceptions.VPCAssociationAuthorizationNotFound:
        print('- Ignored, no such authorisation', flush=True)
    else:
        print(' - Done', flush=True)
        


# Get user to choose create or delete operation
operation = None
while operation not in ('create', 'delete'):
    print('Create or delete authorisations? (c/d):', end='', flush=True)
    selection = input()
    if selection == 'c':
        operation = 'create'
    elif selection == 'd':
        operation = 'delete'
    else:
        print("Please enter 'c' or 'd'", flush=True)


print('You can ' + operation + ' a single authorisation or a set of authorisations.')
print('A set may be for all Interface VPC Endpoints or for all VPCs, but not both.')


# Get a list of VPC attachments into a list of (vpcId, name, accountId) tuples, starting with an "All" entry.
vpclist = [('', 'All VPCs', '')]
response = ec2client.describe_transit_gateway_vpc_attachments()
for attach in response['TransitGatewayVpcAttachments']:
    vpcid = attach['VpcId']
    ownerid = attach['VpcOwnerId']
    # Find the Name tag
    name = ''
    tags = attach.get('Tags', [])
    for tag in tags:
        if tag['Key'] == 'Name':
            name = tag['Value']
    vpclist.append ((vpcid, name, ownerid))   


# Get user to select a VPC or all VPCs
print('')
print('Select one of the following:')
for index, vpc in enumerate(vpclist):
   vpctext = (' - ' + vpc[0] + ' in ' + vpc[2]) if vpc[0] else ''
   print(str(index) + ': ' + vpc[1] + vpctext) 
vpcselection = -1
while not (0 <= vpcselection < len(vpclist)):
    print('0 - ' + str(len(vpclist) - 1) + '?: ', end='', flush=True)
    try:
        vpcselection = int(input())
    except ValueError:
        pass


# Keep just the selected VPC(s)
if vpcselection == 0:
    vpclist = vpclist[1:]
else:
    vpclist = [vpclist[vpcselection]]


# For a delete operation or if a single VPC was selected, we can allow
# the "All" option with private hosted zones.
# Otherwise not ... we would exceed our AWS quota.
zones = []
lowestzone = 0
if (operation == 'create') and (vpcselection == 0):
    zones.append((None, None))
    lowestzone = 1
else:
    zones.append(('', 'All Interface VPC Endpoints'))


# Get all the private hosted zones for the endpoints
response = client.list_hosted_zones(
    MaxItems='100'
)
for zone in response['HostedZones']:
    if zone['Config']['PrivateZone']:
        zone_id = zone['Id'][12:]
        zone_name = zone['Name']
        zone_comment = zone.get('Config', {}).get('Comment', '')
        zones.append ((zone_id, zone_name + ' (' + zone_comment + ')'))


# Get the user to select a PHZ, or (if option given to them), all PHZs.
print('')
print('Select one of the following:')
for index, zone in enumerate(zones):
   if zone[1]:
       print(str(index) + ': ' + zone[1] + ' - ' + zone[0]) 
zoneselection = -1
while not (lowestzone <= zoneselection < len(zones)):
    print(str(lowestzone) + ' - ' + str(len(zones) - 1) + '?: ', end='', flush=True)
    try:
        zoneselection = int(input())
    except ValueError:
        pass


# Keep just the selected Endpoint(s)
if zoneselection == 0:
    zones = zones[1:]
else:
    zones = [zones[zoneselection]]


# Iterate over all VPCs and PHZs selected, performing the create or delete operation.
for vpcid in vpclist:
    for zone in zones:
        print('Executing: ' + operation + ' authorisation for ' + vpcid[1] + ' association to ' + zone[1] + '... ', flush=True)
        response = run_auth_operation (
            eval('client.' + operation + '_vpc_association_authorization'),
            zone[0],
            vpcid[0]       
        )


if operation == 'create':
   print('After associations have been actioned, make sure you repeat your selections')
   print('above with a delete operation to clean up, or we may exceed our quota!')
