<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Copy_Greater_Region</fullName>
        <field>ASI_CRM_CN_Copy_Great_Region__c</field>
        <formula>ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Greater_Region__r.ASI_CRM_EN_name__c</formula>
        <name>ASI CRM CN Copy Greater Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Copy_Greater_Region_Code_Area</fullName>
        <field>ASI_CRM_CN_Greater_Region_Code_Text__c</field>
        <formula>ASI_CRM_CN_Greater_Region_Code__c</formula>
        <name>ASI CRM CN Copy Greater Region Code Area</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_Copy_Greater_Region</fullName>
        <actions>
            <name>ASI_CRM_CN_Copy_Greater_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_CN_Area__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN Area</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_CN_Area__c.ASI_CRM_CN_Greater_Region_Code__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_CN_Copy_Greater_Region_Code_Area</fullName>
        <actions>
            <name>ASI_CRM_CN_Copy_Greater_Region_Code_Area</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_CN_Area__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN Area</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_CN_Area__c.ASI_CRM_CN_Greater_Region_Code__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
