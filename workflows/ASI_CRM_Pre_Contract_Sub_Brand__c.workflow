<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_PreContract_Grade</fullName>
        <field>ASI_CRM_Grade__c</field>
        <formula>ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name</formula>
        <name>ASI_CRM_CN_PreContract_Grade</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_PreContract_Grade_WF</fullName>
        <actions>
            <name>ASI_CRM_CN_PreContract_Grade</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Pre_Contract_Sub_Brand__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN Pre-Contract Sub Brand</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
