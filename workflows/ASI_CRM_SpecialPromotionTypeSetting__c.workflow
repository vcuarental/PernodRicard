<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_Special_Promotion_Setting_Key</fullName>
        <field>ASI_CRM_Promotion_Type_Key__c</field>
        <formula>RecordType.DeveloperName + &quot;_&quot; +  TEXT(ASI_CRM_Promotion_Type__c)</formula>
        <name>ASI CRM Special Promotion Setting Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM Special Promotion Setting Key</fullName>
        <actions>
            <name>ASI_CRM_Special_Promotion_Setting_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_SpecialPromotionTypeSetting__c.ASI_CRM_Promotion_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
