<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Copy_Division_Code</fullName>
        <field>ASI_CRM_CN_Division_Code__c</field>
        <formula>ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Division_Code__c</formula>
        <name>ASI CRM CN Copy Division Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Copy_Greater_Region_Code</fullName>
        <field>ASI_CRM_Greater_Region_Code__c</field>
        <formula>ASI_CRM_City__r.ASI_CRM_CN_Area__r.ASI_CRM_CN_Greater_Region_Code_Text__c</formula>
        <name>ASI CRM CN Copy Greater Region Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_Copy_Greater_Region_Code</fullName>
        <actions>
            <name>ASI_CRM_CN_Copy_Greater_Region_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_City_Sales_Target__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM CN City Sales Target</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
