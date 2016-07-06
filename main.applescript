-- #########################################################
-- Konteringsmallar för iOrdning/Economacs
-- #########################################################
-- #########################################################
-- #########################################################


-- #########################################################
-- CONFIGURATION
-- #########################################################

-- declare templates according to the following pattern:
-- --------------------------------------------------------------------------------------------
-- {"[Name of your template]", { [ACTION], [ACTION], [ACTION], ... }}
-- [ACTION] = { [Account], is_it_a_debet_account, "[formula to transform the amount, or empty to not transform]" }
-- Example:
-- set t1 to {"Inköp av förbrukningsinventarier", {{5400, true, "amount/1.25"}, {2640, true, "(amount/1.25)*0.25"}, {1930, false, ""}}}
-- ---------------------------------------------------------------------------------------------
-- NOTE that if you use 9999 as the account it will be replaced with the chosen account from the assetOrDebtAccounts list
-- Example:
-- set t1 to {"Inköp av förbrukningsinventarier", {{5400, true, "amount/1.25"}, {2640, true, "(amount/1.25)*0.25"}, {9999, false, ""}}}
-- ---------------------------------------------------------------------------------------------

set templates to {}

set end of templates to {"Banktjänstepaket", {{6570, true, ""}, {9999, false, ""}}}
set end of templates to {"Eget uttag av pengar", {{2013, true, ""}, {9999, false, ""}}}
set end of templates to {"Egna insättningar av pengar", {{2017, false, ""}, {9999, true, ""}}}
set end of templates to {"Inköp av förbrukningsinventarier", {{5400, true, "amount/1.25"}, {2640, true, "(amount/1.25)*0.25"}, {9999, false, ""}}}
set end of templates to {"Inköp av facklitteratur", {{6970, true, "amount/1.06"}, {2640, true, "(amount/1.06)*0.06"}, {9999, false, ""}}}
set end of templates to {"Inköp av kontorsmaterial", {{6100, true, "amount/1.25"}, {2640, true, "(amount/1.25)*0.25"}, {9999, false, ""}}}
set end of templates to {"Inköp av IT-tjänster inom Sverige", {{6540, true, "amount/1.25"}, {2640, true, "(amount/1.25)*0.25"}, {9999, false, ""}}}
set end of templates to {"Inköp av IT-tjänster från annat EU-land", {{6542, true, ""}, {2645, true, "amount*0.25"}, {2614, false, "amount*0.25"}, {9999, false, ""}}}
set end of templates to {"Inköp av IT-tjänster utanför EU", {{6543, true, ""}, {2645, true, "amount*0.25"}, {2614, false, "amount*0.25"}, {9999, false, ""}}}

-- If you use 9999 in your templates above they will be replaced with the account the user picks from this list
-- Note 1: this is an optional feature
-- Note 2: this strings below must start with a 4-digit account number
set assetOrDebtAccounts to {"1923 Kreditkortskonto", "1920 Affärskonto", "1930 Bank, checkräkningskonto", "2017 Egna insättningar"}



-- to make script move slower so you can see what happens, set debugDelay to 1
set debugDelay to 0

-- NOTE: possible improvement is to use "script object" instead of lists?




-- #########################################################
-- APPLICATION LOGIC
-- #########################################################

-- pluck names from templates list
set names to {}
repeat with name in templates
	set end of names to get item 1 in name
end repeat

activate

-- show UI with list of templates
choose from list names with title "Konteringsmallar" with prompt "Välj konteringsmall" default items (get item 1 in names)
set chosenName to result as text

-- http://stackoverflow.com/questions/8621290/how-to-tell-an-applescript-to-stop-executing
if chosenName is "false" then
	error number -128
end if

-- set chosenTemplate manually. There is probably a better way to do this.
set chosenTemplate to {}
set counter to 1
repeat with name in names
	-- for some reason name = chosenName does not work. Internet says string comparasion should work.. 
	if name & "STR_END" contains chosenName & "STR_END" then
		set chosenTemplate to (get item counter in templates)
	end if
	set counter to counter + 1
end repeat

-- display UI to enter amount
display dialog (get item 1 of chosenTemplate) default answer "100,00"
set amount to (text returned of result) as real


set usesNine to false

repeat with actionList in (get item 2 of chosenTemplate)
	if (get item 1 in actionList) is 9999 then
		set usesNine to true
	end if
end repeat

if usesNine then
	choose from list assetOrDebtAccounts with title "" with prompt "Välj tillgångs- eller skuldkonto att boka mot" default items (get item 1 in assetOrDebtAccounts)
	set chosenAssetOrDebtAccountText to result as string
	set chosenAssetOrDebtAccount to (text 1 thru 4 of chosenAssetOrDebtAccountText) as integer
end if

delay 0.2 + debugDelay
tell application "Economacs"
	activate
	delay 0.2 + debugDelay
	
	-- click the + button
	-- ref: http://n8henrie.com/2013/03/a-strategy-for-ui-scripting-in-applescript/
	tell application "System Events" to tell process "Economacs"
		set frontmost to true
		delay 0.2 + debugDelay
		
		tell window 1
			tell splitter group 1
				tell group 1
					tell button 1
						perform action "AXPress"
					end tell
				end tell
			end tell
		end tell
	end tell
	
	delay 0.2 + debugDelay
	
	set counter to 0
	repeat with action in (get item 2 of chosenTemplate)
		set end of action to amount
		delay 0.2 + debugDelay
		
		if (get item 1 of action) is 9999 then
			set item 1 of action to chosenAssetOrDebtAccount
		end if
		
		my write_row(action)
		
		tell application "System Events" to keystroke tab
		
		
		-- if you enter an amount in debet for a cost account and press tab you go to new line
		-- if you enter an amount in debet for a non-cost account and press tab you to to the kredet column
		if (get item 2 in action) and (get item 1 in action) < 4000 then
			tell application "System Events" to keystroke tab
		end if
		
	end repeat
	
	delay 0.1 + debugDelay
	tell application "System Events" to keystroke chosenName
	tell application "System Events" to keystroke return
end tell

on write_row(params)
	-- is there better way of doing this?
	set account to (get item 1 in params) as text
	set isDebet to (get item 2 in params) as boolean
	set amountExpression to (get item 3 in params) as text
	set amount to (get item 4 in params) as real
	
	
	if contents of amountExpression is not "" then
		set expr to "on run {amount}
    " & amountExpression & "
    end run" as string
		set amount to run script {expr} with parameters {amount}
	end if
	
	set amountText to amount as string
	set accountText to account as string
	
	tell application "System Events" to keystroke accountText
	tell application "System Events" to keystroke tab
	tell application "System Events" to keystroke tab
	if not isDebet then
		tell application "System Events" to keystroke tab
	end if
	delay 0.1
	tell application "System Events" to keystroke amountText
end write_row





-- #########################################################
-- UTILITIES
-- #########################################################
on joinList(delimiter, someList)
	set prevTIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set output to "" & someList
	set AppleScript's text item delimiters to prevTIDs
	return output
end joinList




