<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_VN_CS_PopulateTotalAmount</fullName>
        <field>ASI_CRM_VN_Amount__c</field>
        <formula>ASI_CRM_Total_Scheduled_Amount__c  /  ASI_CRM_VN_Quantity__c</formula>
        <name>ASI_CRM_VN_CS_PopulateTotalAmount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sys_Balance_Amount</fullName>
        <field>ASI_CRM_Sys_Balance_Amount__c</field>
        <formula>ASI_CRM_Balance_Amount__c</formula>
        <name>Update Sys Balance Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM VN Populate Balance Amount</fullName>
        <actions>
            <name>Update_Sys_Balance_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(   ISCHANGED(ASI_CRM_VN_Amount__c),  ISCHANGED(ASI_CRM_VN_Quantity__c),   ISCHANGED(ASI_CRM_Commit_Amount__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_VN_CS_PopulateTotalAmount</fullName>
        <actions>
            <name>ASI_CRM_VN_CS_PopulateTotalAmount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_VN_Contract_Expenditure__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM VN Contract Expenditure</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_VN_Contract_Expenditure__c.ASI_CRM_VN_Item__c</field>
            <operation>equals</operation>
            <value>Lump Sum</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
