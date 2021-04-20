<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Update_Prepayment</fullName>
        <field>ASI_MFM_CN_Receipt_Amount_Prepayment__c</field>
        <formula>IF (ASI_MFM_Receipt_Amount_YTD__c &gt; 0, 
MIN( 
(ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_PrePaid_Amount__c - ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Prepaid_amount__c), 
IF (ASI_MFM_Receipt_Amount_YTD__c &gt; ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_Receipt_Amount_YTD__c - 
ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Amount__c, 0 
), 
(ASI_MFM_Receipt_Amount_YTD__c - ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Prepaid_amount__c) 
), 
0 
)</formula>
        <name>Update Prepayment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_JP_PO_Receipt_Set_ETL_Date</fullName>
        <field>ASI_MFM_ETL_Date__c</field>
        <formula>NOW()</formula>
        <name>ASI MFM JP PO Receipt Set ETL Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_KR_PO_Receipt_Set_ETL_Date</fullName>
        <field>ASI_MFM_ETL_Date__c</field>
        <formula>NOW()</formula>
        <name>ASI MFM KR PO Receipt Set ETL Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_Set_PO_Receipt_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_JP_PO_Receipt_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI MFM Set PO Receipt Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ASI_MFM_PO_Receipt__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_Update_Marketing_PO_Delivered</fullName>
        <description>Update Marketing PO Delivered to true</description>
        <field>ASI_MFM_Marketing_Verify__c</field>
        <literalValue>1</literalValue>
        <name>ASI MFM Update Marketing PO Delivered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_Update_Marketing_Verify_False</fullName>
        <field>ASI_MFM_Marketing_Verify__c</field>
        <literalValue>0</literalValue>
        <name>ASI MFM Update Marketing Verify False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_MFM_CN_PREPAYMENT</fullName>
        <actions>
            <name>ASI_MFM_CN_Update_Prepayment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR((ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_PrePaid_Amount__c - ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Prepaid_amount__c )&gt;0,(( ASI_MFM_Receipt_Amount_YTD__c - ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Prepaid_amount__c ) &lt; 0))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_JP_PO_Receipt_ETL_Date</fullName>
        <actions>
            <name>ASI_MFM_JP_PO_Receipt_Set_ETL_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_PO_Receipt__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>JP PO Receipt,JP PO Receipt Read Only</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_PO_Receipt_Item__c.ASI_MFM_ETL__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_JP_PO_Receipt_Update_Marketing_PO_Delivered</fullName>
        <actions>
            <name>ASI_MFM_Update_Marketing_PO_Delivered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED( ASI_MFM_ACC_Verify__c ),PRIORVALUE(ASI_MFM_ACC_Verify__c )=false,CONTAINS(RecordType.DeveloperName, &quot;ASI_MFM_JP&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_JP_PO_Receipt_Update_Marketing_PO_Delivered_False</fullName>
        <actions>
            <name>ASI_MFM_Update_Marketing_Verify_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>ASI_MFM_JP_PO_Receipt_Update_Marketing_PO_Delivered_False</description>
        <formula>AND(ISCHANGED( ASI_MFM_ACC_Verify__c ),PRIORVALUE(ASI_MFM_ACC_Verify__c )=true,CONTAINS(RecordType.DeveloperName, &quot;ASI_MFM_JP&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_KR_PO_Receipt_ETL_Date</fullName>
        <actions>
            <name>ASI_MFM_KR_PO_Receipt_Set_ETL_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_PO_Receipt__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>KR PO Receipt</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_PO_Receipt_Item__c.ASI_MFM_ETL__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_Set_PO_Receipt_Read _Only</fullName>
        <actions>
            <name>ASI_MFM_Set_PO_Receipt_Read_Only</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_PO_Receipt__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>JP PO Receipt</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_PO_Receipt_Item__c.ASI_MFM_Marketing_Verify__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
