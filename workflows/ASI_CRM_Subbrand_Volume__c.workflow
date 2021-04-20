<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Copy_Commercial_Team</fullName>
        <description>Copy Commercial Team from Customer</description>
        <field>ASI_CRM_CN_Commercial_Team__c</field>
        <formula>TEXT(ASI_CRM_Account__r.ASI_CRM_CN_Commercial_Team__c)</formula>
        <name>ASI CRM CN Copy Commercial Team</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Copy_Division_Code</fullName>
        <field>ASI_CRM_CN_Division_Code__c</field>
        <formula>ASI_CRM_Account__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Division_Code__c</formula>
        <name>ASI CRM CN Copy Division Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Copy_Greater_Region_Code</fullName>
        <field>ASI_CRM_CN_Greater_Region_Code__c</field>
        <formula>ASI_CRM_Account__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_CN_Greater_Region_Code_Text__c</formula>
        <name>ASI CRM CN Copy Greater Region Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Sub_Brand_Vol_Set_Region</fullName>
        <field>ASI_CRM_CN_Region__c</field>
        <formula>ASI_CRM_Account__r.ASI_CRM_CN_Region__c</formula>
        <name>Sub-Brand Vol - Set Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Sub_Brand_Vol_Set_WS_Tier</fullName>
        <field>ASI_CRM_CN_WS_Tier__c</field>
        <formula>TEXT(ASI_CRM_Account__r.ASI_CRM_CN_WS_Tier__c )</formula>
        <name>Sub-Brand Vol - Set WS Tier</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_Copy_Commercial_Team</fullName>
        <actions>
            <name>ASI_CRM_CN_Copy_Commercial_Team</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Subbrand_Volume__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN WS/Outlet Sub-brand Volume</value>
        </criteriaItems>
        <description>Copy Commercial Team from Customer</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_CN_Copy_Greater_Region_Code</fullName>
        <actions>
            <name>ASI_CRM_CN_Copy_Greater_Region_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Subbrand_Volume__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN WS/Outlet Sub-brand Volume</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_Subbrand_Volume__c.ASI_CRM_CN_WS_Tier__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <description>Copy greater region code from Customer</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_CN_Sub_Brand_Vol_Update_Values</fullName>
        <actions>
            <name>ASI_CRM_CN_Sub_Brand_Vol_Set_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_Sub_Brand_Vol_Set_WS_Tier</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Subbrand_Volume__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN WS/Outlet Sub-brand Volume</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
