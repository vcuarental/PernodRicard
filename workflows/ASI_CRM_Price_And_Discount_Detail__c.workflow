<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_PnD_RollUp_GrossSalesImapct</fullName>
        <field>ASI_CRM_CN_Gross_Sales_Impact_RollUp__c</field>
        <formula>ASI_CRM_Gross_Sales_Impact__c</formula>
        <name>CN PnD RollUp GrossSalesImapct</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Benchmark_Price_from_S</fullName>
        <field>ASI_CRM_SG_SKU_Benchmark_Price1__c</field>
        <formula>ASI_CRM_SG_SKU_Price_Cost__r.ASI_CRM_Price__c</formula>
        <name>SG Update Benchmark Price from SKU Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Benchmark_Price_if_No</fullName>
        <description>(Obsolete): Leave &quot;SKU Benchmark Price&quot; as blank if SKU does not have reference price. No need for an extra workflow rule to fill the price as $0</description>
        <field>ASI_CRM_SG_SKU_Benchmark_Price1__c</field>
        <formula>0</formula>
        <name>ASI CRM SG Update Benchmark Price if No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Budget_Net_Price_Man</fullName>
        <field>ASI_CRM_SG_Budget_Net_Price_Manual__c</field>
        <formula>ASI_CRM_SG_Budget_Net_Price__c</formula>
        <name>ASI CRM SG Update Budget Net Price Man</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_New_Net_Price_Manual</fullName>
        <description>(Obsolete) Changed to use process builder</description>
        <field>ASI_CRM_SG_New_Net_Price_Manual__c</field>
        <formula>ASI_CRM_SG_Price_to_Wholesaler_Outlet__c - ASI_CRM_SG_FWO_Rebate_Per_Bottle__c - ASI_CRM_SG_Portfolio_Rebate_Per_Bottle__c - ASI_CRM_OOM_Rebate_Per_Bottle__c - ASI_CRM_SG_Bottle_Rebate_Per_Bottle__c</formula>
        <name>SG Update New Net Price (Manual)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Price_and_Detail</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG - Update Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM SG - Update Record Type from Price and Discount</fullName>
        <actions>
            <name>ASI_CRM_SG_Update_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Price_And_Discount__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Master Price Group,SG Versioning Price Group</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM SG Update Benchmark Price from SKU Price Cost</fullName>
        <actions>
            <name>ASI_CRM_SG_Update_Benchmark_Price_from_S</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_SG_Update_Budget_Net_Price_Man</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Price_And_Discount_Detail__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Price and Detail</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM SG Update Benchmark Price if No SKU Price Cost</fullName>
        <actions>
            <name>ASI_CRM_SG_Update_Benchmark_Price_if_No</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_SG_Update_Budget_Net_Price_Man</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_SG_Update_New_Net_Price_Manual</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>(Obsolete): Leave &quot;SKU Benchmark Price&quot; as blank if SKU does not have reference price. No need for an extra workflow rule to fill the price as $0</description>
        <formula>isblank( ASI_CRM_SG_SKU_Price_Cost__c ) &amp;&amp;  RecordType.DeveloperName = &quot;ASI_CRM_SG_Price_and_Detail&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_CN_PnD_RollUpGSI</fullName>
        <actions>
            <name>ASI_CRM_CN_PnD_RollUp_GrossSalesImapct</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Price_And_Discount__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN Customer Price and Discount Request,CN Customer Price and Discount Request RO</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
