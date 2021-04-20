<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Copy_Greater_Region_Code</fullName>
        <field>ASI_CRM_Greater_Region_Code__c</field>
        <formula>ASI_CRM_Customer__r.ASI_CRM_CN_Greater_Region_Code__c</formula>
        <name>ASI CRM CN Copy Greater Region Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Empty_Btl_Copy_Division_Code</fullName>
        <field>ASI_CRM_CN_Division_Code__c</field>
        <formula>ASI_CRM_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Division_Code__c</formula>
        <name>ASI CRM CN Empty Btl Copy Division Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Get_WS_Tier_From_Customer</fullName>
        <field>ASI_CRM_WS_Tier__c</field>
        <formula>TEXT( ASI_CRM_Customer__r.ASI_CRM_CN_WS_Tier__c )</formula>
        <name>ASI CRM CN Get WS Tier From Customer</name>
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
            <field>ASI_CRM_Empty_Bottle__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM CN Empty Bottle</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_Empty_Bottle__c.ASI_CRM_WS_Tier__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_CN_Empty_Bottle_Update_WS_Tier</fullName>
        <actions>
            <name>ASI_CRM_CN_Get_WS_Tier_From_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Empty_Bottle__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM CN Empty Bottle</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
