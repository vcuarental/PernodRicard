<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_JP_TnE_Due_Date_Mapping_Name_Update</fullName>
        <field>Name</field>
        <formula>TEXT(YEAR(ASI_JP_TnE_Period_From__c))+&quot;-&quot;+TEXT(MONTH(ASI_JP_TnE_Period_From__c))+&quot;-&quot;+TEXT(DAY(ASI_JP_TnE_Period_From__c))+&quot;~&quot;+TEXT(YEAR(ASI_JP_TnE_Period_To__c))+&quot;-&quot;+TEXT(MONTH(ASI_JP_TnE_Period_To__c))+&quot;-&quot;+TEXT(DAY(ASI_JP_TnE_Period_To__c))</formula>
        <name>ASI TnE JP Due Date Mapping Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_JP_TnE_Due_Date_Mapping_Name_Fill</fullName>
        <actions>
            <name>ASI_JP_TnE_Due_Date_Mapping_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>ASI_JP_TnE_Due_Date_Mapping__c.ASI_JP_TnE_Period_From__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_JP_TnE_Due_Date_Mapping__c.ASI_JP_TnE_Period_To__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
