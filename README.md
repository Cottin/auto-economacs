# Auto-Economacs

There is a beautiful book keeping application for mac called [Economacs (or iOrdning in Swedish)](http://www.iordning.se/sv/hem.html). I've been using it for years and I've always liked its simplicity over more heavy-weight, traditional book keeping applications. Perfect for freelancers with a mac :)

However, Economacs have always been missing a feature called "Konteringsmallar" in Swedish... Maybe translate to something like "templates for assigning account codes" in English ?

Not having this feature is a complete deal-breaker for me. But I realised that it could be built using a simple AppleScript. If you're unsure what this is, have a look at the video below to see the automatic magic that is "Konteringsmallar".

![](https://github.com/Cottin/auto-economacs/blob/master/ae2.gif)


## How to install?

### Without installing any new software
Just use Automator which is included in OS X to create a "Service" to "Run AppleScript", paste the code from my .applescript file and create a shortcut for it in System Preferences.
Here is a simple guide with screen shots: http://superuser.com/questions/815162/how-can-i-run-an-applescript-from-my-mac-with-a-shortcut-without-using-3rd-part

### Using Alfred
Alfred is quite popoular and here is a simple guide for how to run an AppleScript by pressing a shortcut: https://www.alfredapp.com/help/workflows/triggers/hotkey/creating-a-hotkey-workflow/.

### Using Spark
Another option is to use something like Spark: http://www.shadowlab.org/Software/spark

## Add your own templates and accounts
There is one place in the applescript where you can customize the templates in a simple way. Just look at how the existing templates are coded and make the changes you want:

```
set end of templates to {"Eget uttag av pengar", {{2013, true, ""}, {9999, false, ""}}}
set end of templates to {"Egna insättningar av pengar", {{2017, false, ""}, {9999, true, ""}}}
set end of templates to {"Inköp av förbrukningsinventarier", {{5400, true, "amount/1.25"}, {2640, true, "(amount/1.25)*0.25"}, {9999, false, ""}}}
```

There is a second place in the script where you can customize the asset or debt account twoards which the account record is booked:

```
-- If you use 9999 in your templates above they will be replaced with the account the user picks from this list
-- Note 1: this is an optional feature
-- Note 2: this strings below must start with a 4-digit account number
set assetOrDebtAccounts to {"1923 Kreditkortskonto", "1920 Affärskonto", "1930 Bank, checkräkningskonto", "2017 Egna insättningar"}
```
