<#
    .SYNOPSIS
    Sends an SMS text message 
#>
function Send-TwilioSMS {
    [CmdletBinding(DefaultParameterSetName='SpecifyConnectionFields', HelpUri='https://github.com/twilio/twilio-csharp/wiki/Twilio.Api#smsmessage-sendsmsmessage-from-to-body')]
    [OutputType([Twilio.Message])]

    param(
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $From,

        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $To,

        [Parameter(Position=2, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Message")]
        [string]
        $Body,

        [Parameter(ParameterSetName='SpecifyConnectionFields', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AccountSid,

        [Parameter(ParameterSetName='SpecifyConnectionFields', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AuthToken,

        [Parameter(ParameterSetName='UseConnectionObject', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Connection
    )

    $TwilioApi = CreateTwilioApi -Connection $Connection -AccountSid $AccountSid -AuthToken $AuthToken
    
    $To | ForEach-Object {

        $TwilioApi.SendMessage($From, $_, $Body)
    }
}

<#
    .SYNOPSIS
    Gets one or more SMS text messages 
#>
function Get-TwilioSMS {
    [CmdletBinding(HelpUri='https://github.com/twilio/twilio-csharp/wiki/Twilio.Api#void-listsmsmessages-to-from-datesent-pagenumber-count-callback')]
    [OutputType([Twilio.SMSMessage])]

    param(
        [Parameter(Position=0, Mandatory=$true, ParameterSetName='ById')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Sid,

        [Parameter(ParameterSetName='ByFilter')]
        [ValidateNotNullOrEmpty()]
        [string]
        $To,

        [Parameter(ParameterSetName='ByFilter')]
        [ValidateNotNullOrEmpty()]
        [string]
        $From,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $AccountSid,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $AuthToken,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Connection
    )

    $TwilioApi = CreateTwilioApi -Connection $Connection -AccountSid $AccountSid -AuthToken $AuthToken

    if($Sid) {
        $Sid | ForEach-Object {
            $TwilioApi.GetSmsMessage($Sid)  
        }
    }
    else {
        $Response = $TwilioApi.ListSmsMessages($To, $From, $Null, $Null, $Null)
        $Response.SMSMessages
    }
}

<#
    .SYNOPSIS
    Gets all outgoing phone numbers for this Twilio account 
#>
function Get-TwilioPhoneNumbers {
    [CmdletBinding(DefaultParameterSetName='SpecifyConnectionFields', HelpUri='https://github.com/twilio/twilio-csharp/wiki/Twilio.Api#incomingphonenumberresult-listincomingphonenumbers-')]
    [OutputType([Twilio.IncomingPhoneNumber])]

    param(
        [Parameter(ParameterSetName='SpecifyConnectionFields', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AccountSid,

        [Parameter(ParameterSetName='SpecifyConnectionFields', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AuthToken,

        [Parameter(ParameterSetName='UseConnectionObject', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Connection
    )

    $TwilioApi = CreateTwilioApi -Connection $Connection -AccountSid $AccountSid -AuthToken $AuthToken

    $Response = $TwilioApi.ListIncomingPhoneNumbers()

    $Response.IncomingPhoneNumbers
}

function CreateTwilioApi {
    Param(
        [string] $AccountSid,
        [string] $AuthToken,
        [Hashtable] $Connection
    )

    if(!$Connection -and (!$AuthToken -or !$AccountSid)) {
        throw("No connection data specified. You must use either the Connection parameter, or the AccountSid and AuthToken parameters.")
    }

    if(!$Connection) {
        $Con = @{}
    }
    elseif(!$Connection.AccountSid -or !$Connection.AuthToken) {
        throw("Connection object must contain AccountSid and AuthToken properties.")
    }
    else {
        $Con = @{
            AccountSid = $Connection.AccountSid;
            AuthToken = $Connection.AuthToken
        }
    }

    if($AccountSid) {
        $Con.AccountSid = $AccountSid
    }

    if($AuthToken) {
        $Con.AuthToken = $AuthToken
    }

    return New-Object Twilio.TwilioRestClient -ArgumentList @($Con.AccountSid, $Con.AuthToken)
}

Export-ModuleMember Send-TwilioSMS, Get-TwilioSMS, Get-TwilioPhoneNumbers