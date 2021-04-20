<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Competitor_Contract_Line_CR12</fullName>
        <field>ASI_CRM_Volume_CR12WF__c</field>
        <formula>ASI_CRM_Contract_Volume_monthly__c * ASI_CRM_Sub_brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c *1.5</formula>
        <name>ASI_CRM_CN_Competitor_Contract_Line_CR12</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_Competitor_Contract_Line_CR12Vol</fullName>
        <actions>
            <name>ASI_CRM_CN_Competitor_Contract_Line_CR12</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
