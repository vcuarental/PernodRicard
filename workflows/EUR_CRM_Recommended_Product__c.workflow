<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_Update_Has_Status</fullName>
        <field>EUR_CRM_Has_Status__c</field>
        <literalValue>1</literalValue>
        <name>EUR Update Has Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR Recom Product Has status</fullName>
        <actions>
            <name>EUR_Update_Has_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Recommended_Product__c.EUR_CRM_Confirmation__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Recommended_Product__c.EUR_CRM_Confirmation__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <description>Update checkbos Has Status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
