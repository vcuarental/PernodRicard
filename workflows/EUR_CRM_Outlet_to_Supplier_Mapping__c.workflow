<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_CRM_FU_Set_SupplierIsActive_To_False</fullName>
        <field>EUR_CRM_Supplier_is_Active__c</field>
        <literalValue>0</literalValue>
        <name>EUR_CRM_FU_Set_SupplierIsActive_To_False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_FU_Set_SupplierIsActive_To_True</fullName>
        <field>EUR_CRM_Supplier_is_Active__c</field>
        <literalValue>1</literalValue>
        <name>EUR_CRM_FU_Set_SupplierIsActive_To_True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR_CRM_WF_Set_SupplierIsActive_To_False</fullName>
        <actions>
            <name>EUR_CRM_FU_Set_SupplierIsActive_To_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNULL(EUR_CRM_Supplier_Account__c)) &amp;&amp;  ISPICKVAL(EUR_CRM_Supplier_Account__r.EUR_CRM_Status__c, &apos;Inactive&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR_CRM_WF_Set_SupplierIsActive_To_True</fullName>
        <actions>
            <name>EUR_CRM_FU_Set_SupplierIsActive_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNULL(EUR_CRM_Supplier_Account__c))  &amp;&amp;   ISPICKVAL(EUR_CRM_Supplier_Account__r.EUR_CRM_Status__c, &apos;Active&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
