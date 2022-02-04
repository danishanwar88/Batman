
param(
        
        [Parameter(Mandatory = $true)]
        $storagenameinput,
        [Parameter(Mandatory = $true)]
        $aad_admin_objectid
)
$root = "."
$storagename = $storagenameinput.tolower()

if (!(Get-AzStorageAccount -ResourceGroupName "ProjectSQL" -Name $storagename))
{  
    Write-Host "Storage account with $storagename doesn't exisit we will create it in deployment because we are Batman"
}
else {
    Write-Host "Volla storage account $storagename is valid one sit tight and enjoy the ride"
}

if (!(Get-AzureADServicePrincipal -ObjectID $aad_admin_objectid))
{  
    throw "SPN with $aad_admin_objectID doesn't exisit, Batman is not everywhere so we can't proceed."
}
else {
    Write-Host "Volla SPN $aad_admin_objectid is valid one sit tight and enjoy the ride"
}
function get-jsonParameters {

    [CmdletBinding(
       SupportsShouldProcess = $true,
       ConfirmImpact = "High"
   )]

   param(
       [parameter(Mandatory = $true)]
       $parameterSource,

       [parameter(Mandatory = $false)]
       [string]$extension = "parameters.json",

       [Parameter(Mandatory = $False)]
       [String]$jsonCatagory,

       [Parameter(Mandatory = $false)]
       [String]$jsonItemName
   )


   if ($parameterSource) {

       Write-verbose "    - Scanning for parameter files in: $parameterSource"

       [array]$jsonFiles = (Get-ChildItem $parameterSource -Filter "*.$extension" -Recurse)

       Write-verbose "    - Found this amount of files: $($jsonFiles.Count)"

   }

   else {

       Write-Warning "No parameter source provided"

   }



   # Preload content if all GIT custom roles. This is used to find custom roles in Azure that are not defined in GIT

   $Parameters = @()

   if ($jsonFiles.count -gt 0) {

       $jsonFiles.foreach{

           $jsonContent = get-content $($_.FullName) | convertfrom-json

           if (!([string]::IsNullOrEmpty($jsonItemName))) {

               [array]$jsonContent = $jsonContent.$jsonCatagory | Where-Object { $_.name -eq $jsonItemName }

           }

           $Parameters += $jsonContent

       }

   } return $Parameters

}


$paramfile = "$($root)\parameters.json"
$JsonData = Get-Content $paramfile -raw | ConvertFrom-Json
$JsonData.parameters.storname.value = $storagename
$JsonData.parameters.aad_admin_objectid.value = $aad_admin_objectid
$jsondata | convertto-json -depth 99 | out-file ".\parameters.json"


New-AzResourceGroupDeployment -DeploymentName "Wakanda" -ResourceGroupName 'ProjectSQL' `
 -TemplateParameterFile C:\Users\danis\Downloads\ProjectSQL\parameters.json `
 -TemplateFile C:\Users\danis\Downloads\ProjectSQL\Temp.json