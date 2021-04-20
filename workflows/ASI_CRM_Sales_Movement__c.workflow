<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_TW_Copy_Account_Channel</fullName>
        <field>ASI_CRM_Channel_Code__c</field>
        <formula>TEXT( ASI_CRM_Account__r.ASI_HK_CRM_Channel_Detail__c )</formula>
        <name>ASI CRM TW Copy Account Channel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM TW Copy Account Channel</fullName>
        <actions>
            <name>ASI_CRM_TW_Copy_Account_Channel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Sales_Movement__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI_CRM_TW_SalesMovement</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
