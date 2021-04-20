<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_ISP_AccountVendor</fullName>
        <field>EUR_ISP_External_ID_Account_ERP_ID_Vendo__c</field>
        <formula>CASESAFEID (EUR_ISP_Account__r.Id) + EUR_ISP_Vendor__r.EUR_ISP_ERP_ID__c</formula>
        <name>EUR ISP AccountVendor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR_ISP_AccountVendor</fullName>
        <actions>
            <name>EUR_ISP_AccountVendor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Will prove if the Account SF ID and Vendor ERP ID are unique.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
