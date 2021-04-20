<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_TH_CRM_EstimatedSpendingName</fullName>
        <field>Name</field>
        <formula>TEXT(YEAR( ASI_TH_CRM_Date__c)) + &apos; - &apos; + 
CASE(MONTH( ASI_TH_CRM_Date__c),
1,&apos;Jan&apos;,
2,&apos;Feb&apos;,
3,&apos;Mar&apos;,
4,&apos;Apr&apos;,
5,&apos;May&apos;,
6,&apos;Jun&apos;,
7,&apos;Jul&apos;,
8,&apos;Aug&apos;,
9,&apos;Sep&apos;,
10,&apos;Oct&apos;,
11,&apos;Nov&apos;,
12,&apos;Dec&apos;,&apos;&apos;)</formula>
        <name>ASI_TH_CRM_EstimatedSpendingName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_TH_CRM_EstimatedSpendingName</fullName>
        <actions>
            <name>ASI_TH_CRM_EstimatedSpendingName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TH_CRM_Estimated_Spending__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI TH CRM Estimated Spending</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
