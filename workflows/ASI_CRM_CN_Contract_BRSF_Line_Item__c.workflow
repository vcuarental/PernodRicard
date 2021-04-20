<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_UpdateContractTotal</fullName>
        <field>ASI_CRM_CN_Contract_Total_Dummy__c</field>
        <formula>ASI_CRM_CN_Contract_Total__c</formula>
        <name>ASI CRM CN Update Contract Total</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_UpdateContractTotal</fullName>
        <active>true</active>
        <formula>ISCHANGED(ASI_CRM_CN_Contract_Total__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
