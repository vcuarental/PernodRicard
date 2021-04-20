<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_ISP_AccountSku</fullName>
        <field>EUR_ISP_External_ID_Account_SKU__c</field>
        <formula>CASESAFEID (EUR_ISP_Account__r.Id) + EUR_ISP_SKU__r.EUR_CRM_External_ID__c</formula>
        <name>EUR ISP AccountSku</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR_ISP_AccountSku</fullName>
        <actions>
            <name>EUR_ISP_AccountSku</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Will prove if the Account SF ID and SKU External ID is unique.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
