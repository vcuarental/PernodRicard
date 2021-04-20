<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_eForm_Set_CIO_Approve_Required_Off</fullName>
        <field>ASI_eForm_CIO_Approve_Required__c</field>
        <literalValue>0</literalValue>
        <name>ASI eForm Set CIO Approve Required Off</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_Set_CIO_Approve_Required_On</fullName>
        <field>ASI_eForm_CIO_Approve_Required__c</field>
        <literalValue>1</literalValue>
        <name>ASI eForm Set CIO Approve Required On</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_Set_FD_Approve_Required_On</fullName>
        <field>ASI_eForm_FD_Approve_Required__c</field>
        <literalValue>1</literalValue>
        <name>ASI eForm Set FD Approve Required On</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_eForm_HK_Free_CIO_Approve</fullName>
        <actions>
            <name>ASI_eForm_Set_CIO_Approve_Required_Off</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_eForm_IT_Procurement_Service_Item__c.ASI_eForm_HASRF_Category__c</field>
            <operation>notEqual</operation>
            <value>New SW - Non Listed</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_eForm_IT_Procurement_Service_Item__c.ASI_eForm_ITSRF_Category__c</field>
            <operation>notEqual</operation>
            <value>Personal Software Installation</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_eForm_IT_Procurement_Service_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Hardware &amp; Software Request (HK),IT Service Request (HK)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_eForm_HK_Require_CIO_Approve</fullName>
        <actions>
            <name>ASI_eForm_Set_CIO_Approve_Required_On</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>ASI_eForm_IT_Procurement_Service_Item__c.ASI_eForm_HASRF_Category__c</field>
            <operation>equals</operation>
            <value>New SW - Non Listed</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_eForm_IT_Procurement_Service_Item__c.ASI_eForm_ITSRF_Category__c</field>
            <operation>equals</operation>
            <value>Personal Software Installation</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_eForm_IT_Procurement_Service_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Hardware &amp; Software Request (HK),IT Service Request (HK)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_eForm_HK_Require_FD_Approve</fullName>
        <actions>
            <name>ASI_eForm_Set_FD_Approve_Required_On</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>ASI_eForm_IT_Procurement_Service_Item__c.ASI_eForm_HASRF_Category__c</field>
            <operation>equals</operation>
            <value>New Hardware,New Notebook with docking,New Notebook without docking</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_eForm_IT_Procurement_Service_Item__c.ASI_eForm_HASRF_Category__c</field>
            <operation>startsWith</operation>
            <value>New SW</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_eForm_IT_Procurement_Service_Item__c.ASI_eForm_HASRF_Category__c</field>
            <operation>equals</operation>
            <value>IT Related Subscription Items,Non IT Related Subscription Items</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_eForm_IT_Procurement_Service_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Hardware &amp; Software Request (HK)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
