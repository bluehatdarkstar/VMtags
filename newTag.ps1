#Important!!!
#You must run this script once or you'll gonna open 2 connection to VIServer.
#You can select and run only part of this script as weel, skipping connection parameters, once it's already connected to VIServer.

#region Global Variables
 
$rootFolder = "C:\PowerCLI\"
$vcenterAddr = "brhqvcenter.la.loreal.intra"
$userName = "administrator@vsphere.local"
$password = 'SB01#srv@1'
$csvInfo = $rootFolder + "tag.csv"

#endregion

#region connection parameters
Connect-VIServer -Server $vcenterAddr -Protocol https -User $userName -Password $password

$CMDBInfo = Import-CSV $csvInfo

#endregion

#region search vm and creates a category if doesn't exist

ForEach ($item in $CMDBInfo) 
	{
	$Name = $item.Name
    $Category = $item.Category
	$Tag = $item.Tag
	Try 
	{
		$GetVMTagCat = Get-TagCategory -Name $Category -ErrorAction Stop
		Write-Host "TagCategory $GetVMTagCat found"
	}
	Catch
	{
		Write-Host "TagCategory you entered not found, adding $Category as a Category"
		New-TagCategory -Name $Category
		Write-Host "Now, let's add a new Tag under TagCategory:" $Category
		New-Tag -Name $Tag -Category $Category
	}
}
#endregion

#region creating a tag if not or replacing tag for a new one

ForEach ($item in $CMDBInfo)
	{
		$Name = $item.Name
		$Category = $item.Category
		$Tag = $item.Tag
	Try 
	{
		$GetVMTag = Get-Tag -Name $Tag -ErrorAction Stop
		Write-Host "Tag $GetVMTag found"
	}
	Catch
	{
		Write-Host "Tag not found, adding as a NewTag"
		#New-TagCategory -Name $Category
		Write-Host "Now, let's add a new Tag under TagCategory:" $Category
		New-Tag -Name $Tag -Category $Category
	}
		Write-Host ".... Assigning $Tag in Category $Category to $Name "
		$vm = Get-VM -Name $Name
		Get-TagAssignment -Entity $vm | where{$_.Tag.Category.Name -eq "$Category"} | Remove-TagAssignment -Confirm:$false
		New-TagAssignment -Entity $vm -Tag $Tag
	}

#endregion