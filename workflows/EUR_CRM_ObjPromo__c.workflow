<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_CRM_FI_OP_ForEvaluation</fullName>
        <field>EUR_CRM_Status__c</field>
        <literalValue>Under Evaluation</literalValue>
        <name>EUR_CRM_FI_OP_ForEvaluation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Object_Promo_Ended</fullName>
        <field>EUR_CRM_Status__c</field>
        <literalValue>Ended</literalValue>
        <name>EUR_CRM_Object_Promo_Ended</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_UpdateOPEvaluationPeriodEndDate</fullName>
        <field>EUR_CRM_Evaluation_Period_End_Date__c</field>
        <formula>EUR_CRM_Active_End_Date__c + 120</formula>
        <name>EUR_CRM_UpdateOPEvaluationPeriodEndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Update_Status_to_Ended</fullName>
        <field>EUR_CRM_Status__c</field>
        <literalValue>Ended</literalValue>
        <name>EUR CRM Update Status to Ended</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR_CRM_FI_Object_Promo_ForEvaluation</fullName>
        <active>true</active>
        <formula>NOT( ISNULL(  EUR_CRM_Active_End_Date__c ) ) &amp;&amp; (  $RecordType.DeveloperName == &apos;EUR_FI_Off_Trade_O_P&apos; ||  $RecordType.DeveloperName == &apos;EUR_FI_On_Trade_O_P&apos;  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_CRM_FI_OP_ForEvaluation</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>EUR_CRM_ObjPromo__c.EUR_CRM_Active_End_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EUR_CRM_FI_SetOPEvaluationPeriodEndDate</fullName>
        <actions>
            <name>EUR_CRM_UpdateOPEvaluationPeriodEndDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set finland op evaluation period end date to op active end date + 4 months</description>
        <formula>($RecordType.DeveloperName == &apos;EUR_FI_Off_Trade_O_P&apos; ||  $RecordType.DeveloperName == &apos;EUR_FI_On_Trade_O_P&apos;) &amp;&amp;  NOT(ISNULL( EUR_CRM_Active_End_Date__c ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR_CRM_Object_Promo_Ended</fullName>
        <active>true</active>
        <formula>NOT( ISNULL(EUR_CRM_Active_End_Date__c ) ) &amp;&amp; (
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Distribution_Drive&apos; ||
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Leaflet_Campaign&apos; ||
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Sales_Drive&apos; ||
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles&apos; ||
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Sales_Drive_SKU_Displays&apos; ||
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Secondary_Placement_Carton&apos; || 
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Secondary_Placement_Gondelkopf&apos; || 
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Secondary_Placement_Promo_Display&apos; || 
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Secondary_Placement_Razz_Fazz&apos; || 
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Secondary_Placement_Standard&apos; || 
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Secondary_Placement_Theme&apos; || 
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Tasting_Campaign&apos; || 
$RecordType.DeveloperName == &apos;EUR_DE_Off_Trade_Trade_Fair&apos; || 
$RecordType.DeveloperName == &apos;EUR_DE_OnTrade_PROS_TMKT_Promo&apos;  
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_CRM_Object_Promo_Ended</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>EUR_CRM_ObjPromo__c.EUR_CRM_Active_End_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
