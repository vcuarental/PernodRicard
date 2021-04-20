<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Country_Code_From_Account</fullName>
        <description>Set Country code from Account</description>
        <field>EUR_CRM_Country_Code__c</field>
        <formula>EUR_CRM_Account__r.EUR_CRM_Country_Code__c</formula>
        <name>Country Code From Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR Account Group Set Country code from Account</fullName>
        <actions>
            <name>Country_Code_From_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Country Code from lookup Account (EU)</description>
        <formula>ISBLANK(EUR_CRM_Country_Code__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
