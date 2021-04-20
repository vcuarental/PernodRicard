<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_CN_SKUCreationEmail</fullName>
        <description>ASI_CRM_CN_SKUCreationEmail</description>
        <protected>false</protected>
        <recipients>
            <recipient>lika.zhang@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>patrick.yan@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sandy.yang@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sifeng.wu@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_SKU_CreationEmail</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Item_Group_ID_on_SKU</fullName>
        <field>ASI_CRM_SG_Item_Group_ID__c</field>
        <formula>IF( ASI_HK_CRM_Std_Bottle_Size__c = 70 || ASI_HK_CRM_Std_Bottle_Size__c = 75, &quot;SG&quot;&amp; &quot;7075&quot; &amp;  CASESAFEID(ASI_MFM_Sub_brand__r.Id) ,


&quot;SG&quot;&amp; text( CEILING(ASI_HK_CRM_Std_Bottle_Size__c )) &amp; CASESAFEID(ASI_MFM_Sub_brand__r.Id) )</formula>
        <name>ASI CRM SG Update Item Group ID on SKU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Update_SKU_Segment_Type</fullName>
        <description>Update the Segment Type in SKU</description>
        <field>ASI_CRM_VN_Segment_Type__c</field>
        <literalValue>Value</literalValue>
        <name>ASI CRM VN Update SKU Segment Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM SG Update Item Group ID on SKU</fullName>
        <actions>
            <name>ASI_CRM_SG_Update_Item_Group_ID_on_SKU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_SKU_Code__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG SKU</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_MFM_SKU_Code__c.ASI_HK_CRM_IsPOSProduct__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_CN_SKUcreationEmail</fullName>
        <actions>
            <name>ASI_CRM_CN_SKUCreationEmail</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_SKU_Code__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN FOC SKU</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
