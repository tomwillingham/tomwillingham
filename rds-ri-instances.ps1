#!/usr/local/bin/pwsh

# Run AWS CLI command to describe instances and store the output in a variable
$instanceInfo = (aws --profile saml rds describe-reserved-db-instances | ConvertFrom-Json )

# Define an array to store instance details
#$instances = @()
$instances = New-Object System.Collections.ArrayList

# Loop through each instance in the output
foreach ($reservation in $instanceInfo.ReservedDBInstances) {

    #Write-Host "Processing Reservation $($instanceInfo.Reservations)"  -ForegroundColor Cyan
        # Create a custom object to store instance details
        $instanceDetails = [PSCustomObject]@{
            ReservedDBInstanceID          = $reservation.ReservedDBInstanceID
            ReservedDBInstancesOfferingID = $reservation.ReservedDBInstancesOfferingID
            ReservedDBInstanceArn         = $reservation.ReservedDBInstanceArn
            LeaseId                       = $reservation.LeaseId
            DBInstanceClass               = $reservation.DBInstanceClass
            DBInstanceCount               = $reservation.DBInstanceCount
            FixedPrice                    = $reservation.FixedPrice
            UsagePrice                    = $reservation.UsagePrice
            ProductDescription            = $reservation.ProductDescription
            State                         = $reservation.State
            StartTime                     = $reservation.StartTime
            Duration                      = $reservation.Duration
            OfferingType                  = $reservation.OfferingType
            MultiAZ                       = $reservation.MultiAZ
            RecurringAmount               = $reservation.RecurringCharges.RecurringChargeAmount
            RecurringFrequency            = $reservation.RecurringCharges.RecurringChargeFrequency
            # Add more properties as needed
        }

        # Add the custom object to the array
        #$instances += $instanceDetails
        $instances.Add($instanceDetails)|Out-Null
}

# Convert the array of objects into CSV format and output to a file
#$instances.GetEnumerator()| Export-Csv -Path "instance_details.csv" -NoTypeInformation
$instances.GetEnumerator()| ConvertTo-Csv -NoTypeInformation
#$instances.GetEnumerator() | ?{$_.State -eq 'stopped'}
#$instances.GetEnumerator() | ft
