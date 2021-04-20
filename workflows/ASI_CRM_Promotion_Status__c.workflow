<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_TW_Copy_Account_Channel</fullName>
        <field>ASI_CRM_Channel_Code__c</field>
        <formula>ASI_CRM_Customer__r.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c</formula>
        <name>ASI CRM TW Copy Account Channel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_TW_Copy_Region</fullName>
        <field>ASI_CRM_Region_Sharing__c</field>
        <formula>TEXT(ASI_CRM_Account__r.ASI_TH_CRM_Region__c)</formula>
        <name>ASI CRM TW Copy Region</name>
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
            <field>ASI_CRM_Promotion_Status__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>TW Promotion Status</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM TW Copy Region</fullName>
        <actions>
            <name>ASI_CRM_TW_Copy_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Promotion_Status__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>TW Promotion Status</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
