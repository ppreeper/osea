= link:https://www.itprotoday.com/powershell/top-10-active-directory-tasks-solved-powershell[Top 10 Active Directory Tasks Solved with PowerShell]
Using cmdlets is easier than you think
Jeffery Hicks | Nov 17, 2012

Managing Active Directory (AD) with Windows PowerShell is easier than you think -- and I want to prove it to you. Many IT pros think that they must become scripting experts whenever anyone mentions PowerShell. That couldn't be further from the truth. PowerShell is a management engine that you can work with in an interactive management console. It just so happens that you can take those interactive commands and throw them into a script to save typing, but you don't need to script to use PowerShell. You can handle the most common AD management tasks without writing a single script.

Learn more from "Searching and Managing Active Directory Groups with PowerShell"[https://www.itprotoday.com/article/windows-power-tools/searching-managing-ad-groups-powershell-142824] and "Managing AD in Bulk Using PowerShell."[https://www.itprotoday.com/article/active-directory/managing-ad-in-bulk-using-powershell]

== Requirements

To use PowerShell to manage AD, you need to meet a few requirements. I'm going to demonstrate how to use the AD cmdlets from a Windows 7 desktop. (You can also use the free AD cmdlets from Quest Software, in which case the syntax will vary slightly.)

To use the Microsoft cmdlets, you must have a Windows Server 2008 R2 domain controller (DC), or you can download and install the Active Directory Management Gateway Service on legacy DCs. Be sure to read the installation notes carefully; installation requires a DC reboot.

On the client side, download and install Remote Server Administration Tools (RSAT) for either Windows 7 or Windows 8. In Windows 7, you'll need to open Programs in Control Panel and select Turn Windows Features On or Off. Scroll down to Remote Server Administration Tools and expand Role Administration Tools. Select the appropriate check boxes under AD DS and AD LDS Tools, especially the check box for the Active Directory Module for Windows PowerShell, as shown in Figure 1. (In Windows 8, all tools are selected by default.) Now we're ready to roll.

For the sake of simplicity, I've logged on with an account that has domain admin rights. Many of the cmdlets that I'll show allow you to specify alternative credentials. In any case, I recommend reading full cmdlet Help and examples for everything I'm going to show you.

Open a PowerShell session and import the module:

----
PS C:\> Import-Module ActiveDirectory 
----

The import also creates a new PSDrive, but we won't be using it. However, you might want to see which commands are in the module:

----
PS C:\> get-command -module ActiveDirectory
----

The beauty of these commands is that if I can use a command for one AD object, I can use it for 10 or 100 or 1,000. Let's put some of these cmdlets to work.

== Task 1: Reset a User Password

Let's start with a typical IT pro task: resetting a user's password. We can easily accomplish this by using the Set-ADAccountPassword cmdlet. The tricky part is that the new password must be specified as a secure string: a piece of text that's encrypted and stored in memory for the duration of your PowerShell session. So first, we'll create a variable with the new password:

----
PS C:\> $new=Read-Host "Enter the new password" -AsSecureString
----

Next, we'll enter the new password:

----
PS C:\> 
----

Now we can retrieve the account (using the samAccountname is best) and provide the new password. Here's the change for user Jack Frost:

----
PS C:\> Set-ADAccountPassword jfrost -NewPassword $new 
----

Unfortunately, there's a bug with this cmdlet: -Passthru, -Whatif, and -Confirm don't work. If you prefer a one-line approach, try this:

----
PS C:\> Set-ADAccountPassword jfrost -NewPassword (ConvertTo-SecureString -AsPlainText -String "P@ssw0rd1z3" -force) 
----

Finally, I need Jack to change his password at his next logon, so I'll modify the account by using Set-ADUser:

----
PS C:\> Set-ADUser jfrost -ChangePasswordAtLogon $True 
----

The command doesn't write to the pipeline or console unless you use -True. But I can verify success by retrieving the username via the Get-ADUser cmdlet and specifying the PasswordExpired property, shown in Figure 2.

Figure 2: Results of the Get-ADUser Cmdlet with the PasswordExpired Property

The upshot is that it takes very little effort to reset a user's password by using PowerShell. I'll admit that the task is also easily accomplished by using the Microsoft Management Console (MMC) Active Directory Users and Computers snap-in. But using PowerShell is a good alternative if you need to delegate the task, don't want to deploy the Active Directory Users and Computers snap-in, or are resetting the password as part of a larger, automated IT process.

== Task 2: Disable and Enable a User Account

Next, let's disable an account. We'll continue to pick on Jack Frost. This code takes advantage of the `-Whatif` parameter, which you can find on many cmdlets that change things, to verify my command without running it:

----
PS C:\> Disable-ADAccount jfrost -whatif

What if: Performing operation "Set" on Target "CN=Jack Frost,OU=staff,OU=Testing,DC=GLOBOMANTICS,DC=local". 
----

Now to do the deed for real:

----
PS C:\> Disable-ADAccount jfrost
----

When the time comes to enable the account, can you guess the cmdlet name?

----
PS C:\> Enable-ADAccount jfrost 
----

These cmdlets can be used in a pipelined expression to enable or disable as many accounts as you need. For example, this code disables all user accounts in the Sales department:

----
PS C:\> get-aduser -filter "department -eq 'sales'" | disable-adaccount
----

Granted, writing the filter for Get-ADUser can be a little tricky, but that's where using -Whatif with the Disable-ADAccount cmdlet comes in handy.

== Task 3: Unlock a User Account

Now, Jack has locked himself out after trying to use his new password. Rather than dig through the GUI to find his account, I can unlock it by using this simple command:

----
PS C:\> Unlock-ADAccount jfrost 
----

This cmdlet also supports the -Whatif and -Confirm parameters.

== Task 4: Delete a User Account

Deleting 1 or 100 user accounts is easy with the Remove-ADUser cmdlet. I don't want to delete Jack Frost, but if I did, I could use this code:

----
PS C:\> Remove-ADUser jfrost -whatif

What if: Performing operation "Remove" on Target

"CN=Jack Frost,OU=staff,OU=Testing,DC=GLOBOMANTICS,DC=local". 
----

Or I could pipe in a bunch of users and delete them with one simple command:

----
PS C:\> get-aduser -filter "enabled -eq 'false'" -property WhenChanged -SearchBase "OU=Employees,DC=Globomantics,DC=Local" | where {$_.WhenChanged -le (Get-Date).AddDays(-180)} | Remove-ADuser -whatif
----

This one-line command would find and delete all disabled accounts in the Employees organizational unit (OU) that haven't been changed in at least 180 days.

== Task 5: Find Empty Groups

Group management seems like an endless and thankless task. There are a variety of ways to find empty groups. Some expressions might work better than others, depending on your organization. This code will find all groups in the domain, including built-in groups:

----
PS C:\> get-adgroup -filter * | where {-Not ($_ | get-adgroupmember)} | Select Name 
----

If you have groups with hundreds of members, then using this command might be time-consuming; Get-ADGroupMember checks every group. If you can limit or fine-tune your search, so much the better.

Here's another approach:

----
PS C:\> get-adgroup -filter "members -notlike '*' -AND GroupScope -eq 'Universal'" -SearchBase "OU=Groups,OU=Employees,DC=Globomantics,DC=local" | Select Name,Group* 
----

This command finds all universal groups that don't have any members in my Groups OU and that display a few properties. You can see the result in Figure 3.

Figure 3: Finding Filtered Universal Groups

== Task 6: Add Members to a Group

Let's add Jack Frost to the Chicago IT group:

----
PS C:\> add-adgroupmember "chicago IT" -Members jfrost
----

It's that simple. You can just as easily add hundreds of users to a group, although doing so is a bit more awkward than I would like:

----
PS C:\> Add-ADGroupMember "Chicago Employees" -member (get-aduser -filter "city -eq 'Chicago'") 
----

I used a parenthetical pipelined expression to find all users with a City property of Chicago. The code in the parentheses is executed and the resulting objects are piped to the -Member parameter. Each user object is then added to the Chicago Employees group. It doesn't matter whether there are 5 or 500 users; updating group membership takes only a few seconds This expression could also be written using ForEach-Object, which might be easier to follow.

----
PS C:\> Get-ADUser -filter "city -eq 'Chicago'" | foreach {Add-ADGroupMember "Chicago Employees" -Member $_}
----

== Task 7: Enumerate Members of a Group

You might want to see who belongs to a given group. For example, you should periodically find out who belongs to the Domain Admins group:

----
PS C:\> Get-ADGroupMember "Domain Admins" 
----

Figure 4 illustrates the result.

Figure 4: Finding Members of the Domain Admins Group

The cmdlet writes an AD object for each member to the pipeline. But what about nested groups? My Chicago All Users group is a collection of nested groups. To get a list of all user accounts, all I need to do is use the -Recursive parameter:

----
PS C:\> Get-ADGroupMember "Chicago All Users" -Recursive | Select DistinguishedName 
----

If you want to go the other way -- that is, find which groups a user belongs to -- you can look at the user's MemberOf property:

----
PS C:\> get-aduser jfrost -property Memberof | Select -ExpandProperty memberOf CN=NewTest,OU=Groups,OU=Employees,DC=GLOBOMANTICS,DC=local CN=Chicago Test,OU=Groups,OU=Employees,DC=GLOBOMANTICS,DC=local CN=Chicago IT,OU=Groups,OU=Employees,DC=GLOBOMANTICS,DC=local CN=Chicago Sales Users,OU=Groups,OU=Employees,DC=GLOBOMANTICS,DC=local 
----

I used the -ExpandProperty parameter to output the names of MemberOf as strings.

== Task 8: Find Obsolete Computer Accounts

I'm often asked how to find obsolete computer accounts. My response is always, "What defines obsolete?" Different organizations most likely have a different definition for when a computer account (or user account, for that matter) is considered obsolete or no longer in use. Personally, I've always found it easiest to find computer accounts that haven't changed their password in a given number of days. I tend to use 90 days as a cutoff, assuming that if a computer hasn't changed its password with the domain in that period, it's offline and most likely obsolete. The cmdlet to use is Get-ADComputer:

----
PS C:\> get-adcomputer -filter "Passwordlastset -lt '1/1/2012'" -properties *| Select name,passwordlastset 
----

The filter works best with a hard-coded value, but this code will retrieve all computer accounts that haven't changed their password since January 1, 2012. You can see the results in Figure 5.

Figure 5: Finding Obsolete Computer Accounts

Another option, assuming that you're at least at the Windows 2003 domain functional level, is to filter by using the LastLogontimeStamp property. This value is the number of 100 nanosecond intervals since January 1, 1601, and is stored in GMT, so working with this value gets a little tricky:

----
PS C:\> get-adcomputer -filter "LastlogonTimestamp -gt 0" -properties * | select name,lastlogontimestamp,@{Name="LastLogon";Expression={[datetime]::FromFileTime ($_.Lastlogontimestamp)}},passwordlastset | Sort LastLogonTimeStamp 
----

I took the liberty of adding a custom property that takes the LastLogonTimeStamp value and converts it into a friendly date. Figure 6 depicts the result.

Figure 6: Converting the LastLogonTimeStamp Value to a Friendly Date

To create a filter, I need to convert a date, such as January 1, 2012, into the correct format, by converting it to a FileTime:

----
PS C:\> $cutoff=(Get-Date "1/1/2012").ToFileTime()

PS C:\> $cutoff 129698676000000000
----

Now I can use this variable in a filter for Get-ADComputer:

----
PS C:\> Get-ADComputer -Filter "(lastlogontimestamp -lt $cutoff) -or (lastlogontimestamp -notlike '*')" -property * | Select Name,LastlogonTimestamp,PasswordLastSet
----

This query finds the same computer accounts that I found in Figure 5. Because there's a random offset with this property, it doesn't matter which approach you take -- as long as you aren't looking for real-time tracking.

== Task 9: Disable a Computer Account

Perhaps when you find those inactive or obsolete accounts, you'd like to disable them. Easy enough. We'll use the same cmdlet that we use with user accounts. You can specify it by using the account's samAccountname:

----
PS C:\> Disable-ADAccount -Identity "chi-srv01$" -whatif
----

What if: Performing operation "Set" on Target "CN=CHI-SRV01,CN=Computers,DC=GLOBOMANTICS,DC=local".

Or you can use a pipelined expression:

----
PS C:\> get-adcomputer "chi-srv01" | Disable-ADAccount
----

I can also take my code to find obsolete accounts and disable all those accounts:

----
PS C:\> get-adcomputer -filter "Passwordlastset -lt '1/1/2012'" -properties *| Disable-ADAccount 
----

== Task 10: Find Computers by Type

The last task that I'm often asked about is finding computer accounts by type, such as servers or laptops. This requires a little creative thinking on your part. There's nothing in AD that distinguishes a server from a client, other than the OS. If you have a laptop or desktop running Windows Server 2008, you'll need to get extra creative.

You need to filter computer accounts based on the OS. It might be helpful to get a list of those OSs first:

----
PS C:\> Get-ADComputer -Filter * -Properties OperatingSystem | Select OperatingSystem -unique | Sort OperatingSystem 
----

Figure 7 shows what I have to work with.

Figure 7: Retrieving a List of OSs

I want to find all the computers that have a server OS:

----
PS C:\> Get-ADComputer -Filter "OperatingSystem -like '*Server*'" -properties OperatingSystem,OperatingSystem ServicePack | Select Name,Op* | format-list 
----

I've formatted the results as a list, as you can see in Figure 8.

Figure 8

As with the other AD Get cmdlets, you can fine-tune your search parameters and limit your query to a specific OU if necessary. All the expressions that I've shown you can be integrated into larger PowerShell expressions. For example, you can sort, group, filter, export to a comma-separated value (CSV), or build and email an HTML report, all from PowerShell and all without writing a single PowerShell script! In fact, here's a bonus: a user password-age report, saved as an HTML file:

----
PS C:\> Get-ADUser -Filter "Enabled -eq 'True' -AND PasswordNeverExpires -eq 'False'" -Properties PasswordLastSet,PasswordNeverExpires,PasswordExpired | Select DistinguishedName,Name,pass*,@{Name="PasswordAge"; Expression={(Get-Date)-$_.PasswordLastSet}} |sort PasswordAge -Descending | ConvertTo-Html -Title "Password Age Report" | Out-File c:\Work\pwage.htm 
----

Although this one-line command might look intimidating at first, it's pretty simple to follow when you have a little PowerShell experience. The only extra step that I took was to define a custom property called PasswordAge. The value is a timespan between today and the PasswordLastSet property. I then sorted the results on my new property. Figure 9 shows the output from my little test domain.

Figure 9

Ready, Set, Go!

I hope this article has shown you that using PowerShell isn't complicated or frightening. But as with any new tool, test everything I've demonstrated in a non-production environment. If you want to learn more about managing AD with PowerShell, or if you're interested in how you would use Quest cmdlets to accomplish the tasks I discussed in this article, take a look at Managing Active Directory with Windows PowerShell: TFM 2nd Ed. (SAPIEN Press, 2010). As I always tell students in my training sessions, "It isn't a matter of if you'll use PowerShell, only a matter of when." Sure, you can manage AD without using PowerShell, but if you want maximum efficiency with minimal effort, you'll be glad you started using it today.
