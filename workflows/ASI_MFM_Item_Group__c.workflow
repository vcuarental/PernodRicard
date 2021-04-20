<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_CN_ItemGroup_Selective_Notify</fullName>
        <description>ASI CRM CN ItemGroup Selective Notify</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CN_NPL_IT_All</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>ASI_CN_NPL_MKT_Wine_Team</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>ASI_CN_NPL_OPS_All</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CN_NPL_Email_Template/ASI_CN_NPL_Item_Group_Selective_Notify</template>
    </alerts>
    <alerts>
        <fullName>ASI_MFM_CN_POSM_ItemGroup_Duplication_Email_Alert</fullName>
        <description>ASI_MFM_CN_POSM_ItemGroup_Duplication_Email_Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_MFM_CN_POSM_ItemGroup_IT</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_POSM_ItemGroup_Duplication</template>
    </alerts>
    <alerts>
        <fullName>ASI_MFM_CN_POSM_Item_Group_Approved_Notice</fullName>
        <description>ASI_MFM_CN_POSM_Item_Group_Approved_Notice</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_POSM_ItemGroup_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_MFM_CN_POSM_Item_Group_Rejected_Notice</fullName>
        <description>ASI_MFM_CN_POSM_Item_Group_Rejected_Notice</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_MFM_CN_Email_Templates/ASI_MFM_CN_POSM_ItemGroup_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_ItemGroup_CheckSelectiveETL</fullName>
        <field>ASI_CRM_Selective__c</field>
        <literalValue>1</literalValue>
        <name>ASI CRM CN ItemGroup CheckSelectiveETL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_ItemGroup_UnCheckSelectiveETL</fullName>
        <field>ASI_CRM_Selective__c</field>
        <literalValue>0</literalValue>
        <name>ASI CRM CN ItemGroup UnCheckSelectiveETL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Item_Group_Bottle_Size</fullName>
        <field>ASI_CRM_CN_BT_Size_C__c</field>
        <formula>IF( ASI_CRM_CN_BT_Size_C__c = &quot;38&quot; ,
&quot;37.5&quot;, ASI_CRM_CN_BT_Size_C__c)</formula>
        <name>ASI CRM SG Update Item Group Bottle Size</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Item_Group_ID_on_Item</fullName>
        <field>ASI_CRM_Item_Group_ID_For_Product_Group__c</field>
        <formula>IF( ASI_CRM_CN_BT_Size_C__c = &quot;38&quot; || ASI_CRM_CN_BT_Size_C__c = &quot;37.5&quot;, 

&quot;SG&quot;&amp; &quot;38&quot; &amp; CASESAFEID(ASI_MFM_Sub_brand__r.Id),

IF( ASI_CRM_CN_BT_Size_C__c = &quot;70&quot; || ASI_CRM_CN_BT_Size_C__c = &quot;75&quot;, 

&quot;SG&quot;&amp; &quot;7075&quot; &amp; CASESAFEID(ASI_MFM_Sub_brand__r.Id) , 



&quot;SG&quot;&amp; text( CEILING(value( ASI_CRM_CN_BT_Size_C__c ) ))&amp; CASESAFEID(ASI_MFM_Sub_brand__r.Id) ))</formula>
        <name>ASI CRM SG Update Item Group ID on Item</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Item_Group_Name</fullName>
        <field>Name</field>
        <formula>IF( ASI_CRM_CN_BT_Size_C__c = &quot;38&quot; || ASI_CRM_CN_BT_Size_C__c = &quot;37.5&quot;,

ASI_MFM_Sub_brand__r.Name &amp;&quot; &quot;&amp; &quot;37.5&quot;  &amp;&quot; cl&quot;,

ASI_MFM_Sub_brand__r.Name &amp;&quot; &quot;&amp; ASI_CRM_CN_BT_Size_C__c  &amp;&quot; cl&quot;)</formula>
        <name>ASI CRM SG Update Item Group Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Item_Group_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Item_Group</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG Update Item Group Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Active_Utilization_Status</fullName>
        <field>ASI_MFM_Utilization_Status__c</field>
        <literalValue>Active</literalValue>
        <name>ASI_MFM_CN_Active_Utilization_Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Change_to_RO_Region</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_New_POSM_Item_Group_RO_Region</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Change to RO - Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Change_to_RO_Trade</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_New_POSM_Item_Group_RO_Trade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Change to RO - Trade</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_POSM_Clear_NotifyITGroup</fullName>
        <description>After sending email alert, set the Notify_IT_Group to false</description>
        <field>ASI_MFM_NotifyITGroup__c</field>
        <literalValue>0</literalValue>
        <name>ASI_MFM_CN_POSM_Clear_NotifyITGroup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Update_RT_to_Normal</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_New_POSM_Item_Group</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Update RT to Normal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Update_RT_to_Normal_Region</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_New_POSM_Item_Group_Region</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Update RT to Normal - Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Update_RT_to_Normal_Trade</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_New_POSM_Item_Group_Trade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Update RT to Normal - Trade</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Update_RT_to_POSM_Item_Group</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_POSM_Item_Group</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Update RT to POSM Item Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Update_RT_to_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_MFM_CN_New_POSM_Item_Group_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN Update RT to RO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Update_To_Submitted</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>CN Update to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Update_to_Draft</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>CN Update to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_CN_Update_to_Final</fullName>
        <field>ASI_MFM_Status__c</field>
        <literalValue>Final</literalValue>
        <name>CN Update to Final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM CN ItemGroup Selective</fullName>
        <actions>
            <name>ASI_CRM_CN_ItemGroup_Selective_Notify</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_ItemGroup_CheckSelectiveETL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Item_Group__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN CRM Item Group,CN CRM Free Goods</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Item_Group__c.ASI_CRM_Selective_Picklist__c</field>
            <operation>equals</operation>
            <value>SLT</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM CN ItemGroup UnSelective</fullName>
        <actions>
            <name>ASI_CRM_CN_ItemGroup_UnCheckSelectiveETL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Item_Group__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN CRM Item Group,CN CRM Free Goods</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Item_Group__c.ASI_CRM_Selective_Picklist__c</field>
            <operation>equals</operation>
            <value>NSLT</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM SG Update Item Group ID on Item Group</fullName>
        <actions>
            <name>ASI_CRM_SG_Update_Item_Group_ID_on_Item</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Item_Group__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Item Group</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM SG Update Item Group Record Type Upon Auto Creation</fullName>
        <actions>
            <name>ASI_CRM_SG_Update_Item_Group_Bottle_Size</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_SG_Update_Item_Group_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_SG_Update_Item_Group_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ASI_MFM_Sub_brand__r.RecordType.DeveloperName = &quot;ASI_CRM_SG_Sub_brand&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_MFM_CN_POSM_ItemGroup_NotifyITGroup</fullName>
        <actions>
            <name>ASI_MFM_CN_POSM_ItemGroup_Duplication_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_MFM_CN_POSM_Clear_NotifyITGroup</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Item_Group__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN New POSM Item Group - Region,CN New POSM Item Group RO - Region,CN POSM Item Group,CN New POSM Item Group - HQ,CN New POSM Item Group RO - HQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_Item_Group__c.ASI_MFM_NotifyITGroup__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
