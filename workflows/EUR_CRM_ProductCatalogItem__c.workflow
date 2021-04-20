<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_Set_PBI_Product_Name</fullName>
        <field>EUR_CRM_Product_Name_Text__c</field>
        <formula>EUR_CRM_ProductName__c</formula>
        <name>EUR Set PBI Product Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR ZA %3A Make product name searchable</fullName>
        <actions>
            <name>EUR_Set_PBI_Product_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Save Product name on the Price Book Item to make the product searchable from a Price Book Item (EU)</description>
        <formula>EUR_CRM_PriceBookID__r.EUR_CRM_Country__c == &quot;ZA&quot; &amp;&amp;  ISBLANK(EUR_CRM_Product_Name_Text__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
