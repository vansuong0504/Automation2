# +
*** Settings ***
Documentation     All the Keywords implemenentation for Robot2.

Library           RPA.Browser.Selenium
Library           RPA.Excel.Files
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Dialogs
Library           RPA.Robocloud.Secrets
# -

*** Variables ***
#${CSV_FILE_URL}=    https://robotsparebinindustries.com/orders.csv
${GLOBAL_RETRY_AMOUNT}=    10x
${GLOBAL_RETRY_INTERVAL}=    1s
${order_number}

# +
*** Keywords ***

Get the URL from vault and Open the robot order website
    ${url}=    Get Secret    credentials
    Log        ${url}
    Open Available Browser      ${url}[robotsparebin]

Get orders.csv URL from User
    Create Form    Orders.csv URL
    Add Text Input    URL    url
    &{response}    Request Response
    [Return]    ${response["url"]}

Get orders
    ${CSV_FILE_URL}=    Get orders.csv URL from User
    Download        ${CSV_FILE_URL}           overwrite=True
    ${table}=       Read Table From Csv       orders.csv      dialect=excel  header=True
    FOR     ${row}  IN  @{table}
        Log     ${row}
    END
    [Return]    ${table}


Close the annoying modal
    Click Button    OK


Preview the robot
    Click Element    id:preview
    Wait Until Element Is Visible    id:robot-preview
    
Submit the order And Keep Checking Until Success
    Click Element    order
    Element Should Be Visible    xpath://div[@id="receipt"]/p[1]
    Element Should Be Visible    id:order-completion


Submit the order
    Wait Until Keyword Succeeds    ${GLOBAL_RETRY_AMOUNT}    ${GLOBAL_RETRY_INTERVAL}     Submit the order And Keep Checking Until Success


Go to order another robot
    Click Button    order-another
    
    
Create a ZIP file of the receipts
    Archive Folder With Zip  ${CURDIR}${/}output${/}receipts   ${CURDIR}${/}output${/}receipt.zip
