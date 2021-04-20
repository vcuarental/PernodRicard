<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_ISP_UserBrand</fullName>
        <field>EUR_ISP_External_ID_Brand_User_Username__c</field>
        <formula>EUR_ISP_Brand__r.EUR_CRM_External_ID__c + EUR_ISP_User__r.Username</formula>
        <name>EUR_ISP_UserBrand</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR_ISP_UserBrand</fullName>
        <actions>
            <name>EUR_ISP_UserBrand</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Will prove if the Brand External ID and Username are unique.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
