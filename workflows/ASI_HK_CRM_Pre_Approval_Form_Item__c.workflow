<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_HK_Set_PAF_Item_M</fullName>
        <field>ASI_CRM_HK_Community_Marketing__c</field>
        <literalValue>1</literalValue>
        <name>ASI_CRM_HK_Set_PAF_Item_M</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_HK_Set_PAF_Item_T</fullName>
        <field>ASI_CRM_HK_Trade_Marketing__c</field>
        <literalValue>1</literalValue>
        <name>ASI_CRM_HK_Set_PAF_Item_T</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Set_PAF_Item_MKT</fullName>
        <field>ASI_HK_CRM_MKT_Sales__c</field>
        <literalValue>Marketing</literalValue>
        <name>ASI HK CRM Set PAF Item MKT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Set_PAF_Item_Sales</fullName>
        <field>ASI_HK_CRM_MKT_Sales__c</field>
        <literalValue>Sales</literalValue>
        <name>ASI HK CRM Set PAF Item Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Update_SKU_Value</fullName>
        <field>ASI_HK_CRM_SKU_Value__c</field>
        <formula>ASI_HK_CRM_Price__c *  ASI_HK_CRM_Target_Volume_Qty__c</formula>
        <name>ASI HK CRM Update SKU Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI HK CRM Mechanic MKT</fullName>
        <actions>
            <name>ASI_HK_CRM_Set_PAF_Item_MKT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Resp_Department__c, &quot;Marketing&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI HK CRM Mechanic Sales</fullName>
        <actions>
            <name>ASI_HK_CRM_Set_PAF_Item_Sales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Resp_Department__c, &quot;Sales&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI HK CRM SKU Value</fullName>
        <actions>
            <name>ASI_HK_CRM_Update_SKU_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form_Item__c.ASI_HK_CRM_Price__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form_Item__c.ASI_HK_CRM_Target_Volume_Qty__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_HK_Mechanic_M</fullName>
        <actions>
            <name>ASI_CRM_HK_Set_PAF_Item_M</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>CONTAINS(ASI_HK_CRM_Mechanic__r.Name, &apos;M-&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_HK_Mechanic_T</fullName>
        <actions>
            <name>ASI_CRM_HK_Set_PAF_Item_T</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>CONTAINS(ASI_HK_CRM_Mechanic__r.Name, &apos;T-&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
