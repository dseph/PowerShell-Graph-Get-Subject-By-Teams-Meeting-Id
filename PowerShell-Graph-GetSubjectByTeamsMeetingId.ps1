# PowerShell-Graph-GetSubjectByTeamsMeetingId.ps1
# This script demonstrates how to retrieve the subject of a Teams meeting using its meeting ID via Microsoft Graph API.
# Generated initially with CoPilot.
#
#  Read before trying: https://learn.microsoft.com/en-us/graph/api/resources/onlinemeeting?view=graph-rest-1.0
#  Need Application permissions granted:
#    OnlineMeeting.Read.All
#    Be sure to do an administrtor grant after setting the specifc permissions.

<#
.SYNOPSIS
  Get the Subject of a calendar event ("meeting") from Microsoft Graph by Event ID.

.DESCRIPTION
  Uses raw REST calls to Microsoft Graph:
    1) Acquire an app-only access token (client credentials).
    2) GET /users/{user}/events/{eventId}?$select=subject
  Returns the subject string.

  Docs:
    - Get event API (supports $select and /users/{id|UPN}/events/{id}) [1](https://learn.microsoft.com/en-us/graph/api/event-get?view=graph-rest-1.0)

.NOTES
  Permissions:
    - For app-only: Calendars.Read or Calendars.ReadBasic (Application) on Microsoft Graph [1](https://learn.microsoft.com/en-us/graph/api/event-get?view=graph-rest-1.0)
  If you instead want delegated (/me/events/{id}), you’d request delegated scopes and change the URL accordingly.
#>

# =========================
# CONFIGURATION (edit these)
# =========================

# Tenant (Directory) ID (GUID)
$TenantId     = "<tenant-id-guid>"

# App (client) ID (GUID)
$ClientId     = "<app-id-guid>"

# Client secret (value)
$ClientSecret = "<client-secret>"

# Target mailbox that contains the meeting/event.
# You can use a UPN (user@domain.com) or a GUID id. [1](https://learn.microsoft.com/en-us/graph/api/event-get?view=graph-rest-1.0)
$UserIdOrUpn  = "<user@domain.com>"

# The Graph Event ID of the meeting (this is the {id} in /events/{id})
$EventId      = "<event-id>"

# =========================
# 1) Acquire token (app-only)
# =========================

# OAuth2 token endpoint for your tenant
$tokenEndpoint = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

# Body for client credentials flow:
#   scope must be "https://graph.microsoft.com/.default" for app-only tokens.
$tokenBody = @{
  client_id     = $ClientId
  client_secret = $ClientSecret
  scope         = "https://graph.microsoft.com/.default"
  grant_type    = "client_credentials"
}

# Request the token
$tokenResponse = Invoke-RestMethod -Method POST -Uri $tokenEndpoint -Body $tokenBody -ContentType "application/x-www-form-urlencoded"

# Extract bearer token
$accessToken = $tokenResponse.access_token

# =========================
# 2) Call Graph Get event
# =========================

# Build the request URL.
# Use $select=subject so we only fetch what we need (smaller payload). [1](https://learn.microsoft.com/en-us/graph/api/event-get?view=graph-rest-1.0)[3](https://learn.microsoft.com/en-us/graph/query-parameters)
$getUrl = "https://graph.microsoft.com/v1.0/users/" + $UserIdOrUpn + "/events/" + $EventId + "?`$select=subject"

#
# Authorization header
$headers = @{
  Authorization = "Bearer $accessToken"
  Accept        = "application/json"
}
# 
# Make the GET call
$evt = Invoke-RestMethod -Method GET -Uri $getUrl -Headers $headers

# Output just the subject
$evt.subject
