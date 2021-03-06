<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_JP_D_C_ProdPrice_Approved</fullName>
        <description>ASI_CRM_JP_D&amp;C_ProdPrice_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/ASI_CRM_JP_D_C_Product_Price_Approved_Notification_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_D_C_ProdPrice_Rejected</fullName>
        <description>ASI_CRM_JP_D&amp;C_ProdPrice_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/ASI_CRM_JP_D_C_ProductPrice_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_DirectSales_ProdPrice_Approval_Approved</fullName>
        <description>ASI_CRM_JP_DirectSales_ProdPrice_Approval_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/CRM_JP_Direct_Sales_Product_Price_Approved_Notification_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_DirectSales_ProdPrice_Approval_Rejected</fullName>
        <description>ASI_CRM_JP_DirectSales_ProdPrice_Approval_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/CRM_JP_DirectSalesProductPrice_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_Promotion_ProdPrice_Approved</fullName>
        <description>ASI_CRM_JP_Promotion_ProdPrice_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/ASI_CRM_JP_Promotion_Product_Price_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_Promotion_ProdPrice_Rejected</fullName>
        <description>ASI_CRM_JP_Promotion_ProdPrice_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/ASI_CRM_JP_Promotion_Price_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_Wholesaler_ProdPrice_Approved</fullName>
        <description>ASI_CRM_JP_Wholesaler_ProdPrice_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/ASI_CRM_JP_Wholesaler_Product_Price_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_Wholesaler_ProdPrice_Rejected</fullName>
        <description>ASI_CRM_JP_Wholesaler_ProdPrice_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_JP_Email_Templates/ASI_CRM_JP_WholesalerPrice_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_DirectSalesProdPrice_Activate</fullName>
        <field>ASI_CRM_JP_Active__c</field>
        <literalValue>1</literalValue>
        <name>ASI_CRM_JP_DirectSalesProdPrice_Activate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_UpdateJDE</fullName>
        <description>Update the JRE flag after change in Effective to and price is approved</description>
        <field>ASI_CRM_JDE_Synced__c</field>
        <literalValue>0</literalValue>
        <name>ASI_CRM_JP_UpdateJDE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_JP_EffectiveTo_Sync</fullName>
        <actions>
            <name>ASI_CRM_JP_UpdateJDE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Once effective to is updated after price item is approved, uncheck the &quot;Sync to JDE&quot; flag.</description>
        <formula>AND (ASI_CRM_JP_Active__c = TRUE, OR (  RecordType.DeveloperName = &quot;ASI_CRM_JP_Wholesaler_Product_Price&quot;,  RecordType.DeveloperName = &quot;ASI_CRM_JP_Direct_Sales_Product_Price&quot;,  RecordType.DeveloperName = &quot;ASI_CRM_JP_D_C_Product_Price&quot;  ) , ISCHANGED( ASI_Expiry_Date__c ), NOT(ISCHANGED( ASI_CRM_JDE_Synced__c ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
