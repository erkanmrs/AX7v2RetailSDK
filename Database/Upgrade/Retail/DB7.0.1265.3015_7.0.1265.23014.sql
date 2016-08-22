/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

GO

SET NUMERIC_ROUNDABORT OFF;

GO

GO
PRINT N'Altering [crt].[GETPRODUCTIDSBYSEARCHTEXT]...';


GO

ALTER FUNCTION [crt].[GETPRODUCTIDSBYSEARCHTEXT]
(
    @bi_ChannelId               BIGINT,
    @bi_CatalogId               BIGINT,
    @dt_ChannelDate             DATE,
    @i_MaxTop                   INT,  -- This parameter is not respected by default and has been provided for consumers to consciously trade-off accurate results over performance.
    @nvc_Locale                 NVARCHAR(7),
    @nvc_SearchText             NVARCHAR(1000)  -- 1000 because the size of the biggest column being looked up is [ax].ECORESPRODUCTTRANSLATION.DESCRIPTION of type NVARCHAR(1000)
)
RETURNS TABLE
RETURN
SELECT PRODUCTID, SUM(RANKING) AS RANKING
FROM
(
    SELECT [it].PRODUCT AS PRODUCTID, [results_itemId].[RANK] AS RANKING
    FROM CONTAINSTABLE([ax].INVENTTABLE, [ITEMID], @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_itemId
    INNER JOIN [ax].INVENTTABLE it ON [it].RECID = [results_itemId].[KEY]

    UNION ALL
        
    SELECT [erpt].PRODUCT AS PRODUCTID, [results_name].[RANK] AS RANKING
    FROM FREETEXTTABLE([ax].ECORESPRODUCTTRANSLATION, [NAME], @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_name
    INNER JOIN [ax].ECORESPRODUCTTRANSLATION erpt ON [erpt].RECID = [results_name].[KEY]
    WHERE NOT EXISTS (SELECT * FROM [ax].ECORESDISTINCTPRODUCTVARIANT pv WHERE pv.RECID = [erpt].PRODUCT)

    UNION ALL

    SELECT [erpt].PRODUCT AS PRODUCTID, [results_partialName].[RANK] AS RANKING
    FROM CONTAINSTABLE([ax].ECORESPRODUCTTRANSLATION, [NAME], @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_partialName
    INNER JOIN [ax].ECORESPRODUCTTRANSLATION erpt ON [erpt].RECID = [results_partialName].[KEY]
    WHERE NOT EXISTS (SELECT * FROM [ax].ECORESDISTINCTPRODUCTVARIANT pv WHERE pv.RECID = [erpt].PRODUCT)

    UNION ALL
    
    SELECT [erpt].PRODUCT AS PRODUCTID, [results_description].[RANK] AS RANKING
    FROM FREETEXTTABLE([ax].ECORESPRODUCTTRANSLATION, [DESCRIPTION], @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_description
    INNER JOIN [ax].ECORESPRODUCTTRANSLATION erpt ON [erpt].RECID = [results_description].[KEY]
    WHERE NOT EXISTS (SELECT * FROM [ax].ECORESDISTINCTPRODUCTVARIANT pv WHERE pv.RECID = [erpt].PRODUCT)

    UNION ALL

    SELECT [erpmc].COLORPRODUCTMASTER AS PRODUCTID, [results_translatedColor].[RANK] AS RANKING
    FROM FREETEXTTABLE([ax].ECORESPRODUCTMASTERDIMVALUETRANSLATION, NAME, @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_translatedColor
    INNER JOIN [ax].ECORESPRODUCTMASTERDIMVALUETRANSLATION erpmdvt ON [results_translatedColor].[KEY] = [erpmdvt].RECID
    INNER JOIN [ax].ECORESPRODUCTMASTERCOLOR erpmc ON [erpmc].RECID = [erpmdvt].PRODUCTMASTERDIMENSIONVALUE

    UNION ALL

    SELECT [erpmc].CONFIGPRODUCTMASTER AS PRODUCTID, [results_translatedConfiguration].[RANK] AS RANKING
    FROM FREETEXTTABLE([ax].ECORESPRODUCTMASTERDIMVALUETRANSLATION, NAME, @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_translatedConfiguration
    INNER JOIN [ax].ECORESPRODUCTMASTERDIMVALUETRANSLATION erpmdvt ON [results_translatedConfiguration].[KEY] = [erpmdvt].RECID
    INNER JOIN [ax].ECORESPRODUCTMASTERCONFIGURATION erpmc ON [erpmc].RECID = [erpmdvt].PRODUCTMASTERDIMENSIONVALUE

    UNION ALL

    SELECT [erpms].SIZEPRODUCTMASTER AS PRODUCTID, [results_translatedSize].[RANK] AS RANKING
    FROM FREETEXTTABLE([ax].ECORESPRODUCTMASTERDIMVALUETRANSLATION, NAME, @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_translatedSize
    INNER JOIN [ax].ECORESPRODUCTMASTERDIMVALUETRANSLATION erpmdvt ON [results_translatedSize].[KEY] = [erpmdvt].RECID
    INNER JOIN [ax].ECORESPRODUCTMASTERSIZE erpms ON [erpms].RECID = [erpmdvt].PRODUCTMASTERDIMENSIONVALUE

    UNION ALL

    SELECT [erpms].STYLEPRODUCTMASTER AS PRODUCTID, [results_translatedStyle].[RANK] AS RANKING
    FROM FREETEXTTABLE([ax].ECORESPRODUCTMASTERDIMVALUETRANSLATION, NAME, @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_translatedStyle
    INNER JOIN [ax].ECORESPRODUCTMASTERDIMVALUETRANSLATION erpmdvt ON [results_translatedStyle].[KEY] = [erpmdvt].RECID
    INNER JOIN [ax].ECORESPRODUCTMASTERSTYLE erpms ON [erpms].RECID = [erpmdvt].PRODUCTMASTERDIMENSIONVALUE

    UNION ALL

    SELECT [erpmc].COLORPRODUCTMASTER AS PRODUCTID, [results_color].[RANK] AS RANKING
    FROM FREETEXTTABLE([ax].ECORESCOLOR, NAME, @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_color
    INNER JOIN [ax].ECORESPRODUCTMASTERCOLOR erpmc ON [results_color].[KEY] = [erpmc].COLOR

    UNION ALL

    SELECT [erpmc].CONFIGPRODUCTMASTER AS PRODUCTID, [results_configuration].[RANK] AS RANKING
    FROM FREETEXTTABLE([ax].ECORESCONFIGURATION, NAME, @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_configuration
    INNER JOIN [ax].ECORESPRODUCTMASTERCONFIGURATION erpmc ON [results_configuration].[KEY] = [erpmc].CONFIGURATION

    UNION ALL

    SELECT [erpms].SIZEPRODUCTMASTER AS PRODUCTID, [results_size].[RANK] AS RANKING
    FROM FREETEXTTABLE([ax].ECORESSIZE, NAME, @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_size
    INNER JOIN [ax].ECORESPRODUCTMASTERSIZE erpms ON [results_size].[KEY] = [erpms].SIZE

    UNION ALL

    SELECT [erpms].STYLEPRODUCTMASTER AS PRODUCTID, [results_style].[RANK] AS RANKING
    FROM FREETEXTTABLE([ax].ECORESSTYLE, NAME, @nvc_SearchText /*, @i_MaxTop - Use this parameter to retrieve results faster. Warning: Using it may result in fewer results. */) results_style
    INNER JOIN [ax].ECORESPRODUCTMASTERSTYLE erpms ON [results_style].[KEY] = [erpms].STYLE
) results
WHERE EXISTS
        (
            SELECT 1 FROM [crt].LOCALPRODUCTASSORTMENTRULESVIEW par WITH (NOEXPAND)
            WHERE [par].VARIANTID = 0 AND [par].PRODUCTID = results.PRODUCTID AND [par].CHANNELID = @bi_ChannelId AND @dt_ChannelDate BETWEEN [par].VALIDFROM AND [par].VALIDTO --AND [apv].ISREMOTE = 0  -- Search is only supported in locally available channels
        )
        AND
        (
            @bi_CatalogId = 0 OR EXISTS
            (
                SELECT 1 FROM [crt].[PRODUCTCATALOGRULESVIEW] pcrv
                WHERE pcrv.CHANNELID = @bi_ChannelId AND pcrv.CATALOGID = @bi_CatalogId AND pcrv.PRODUCTID = results.PRODUCTID
            )
        )
GROUP BY [results].PRODUCTID
GO
PRINT N'Refreshing [crt].[GETPRODUCTSEARCHRESULTSBYTEXT]...';


GO
EXECUTE sp_refreshsqlmodule N'[crt].[GETPRODUCTSEARCHRESULTSBYTEXT]';


GO
PRINT N'Altering [crt].[GETSHIFTREQUIREDAMOUNTSPERTENDER]...';


GO

ALTER PROCEDURE [crt].[GETSHIFTREQUIREDAMOUNTSPERTENDER]
	@bi_ChannelId						bigint,
	@nvc_TerminalId						nvarchar(10),
	@bi_ShiftId						bigint,
	@nvc_DataAreaId						nvarchar(4)
AS

BEGIN
	SET NOCOUNT ON;

	-- 1. Find the last tender declaration date time
	DECLARE @dtt_StartDateTime datetime;

	SELECT	@dtt_StartDateTime = MAX(RTT.CREATEDDATETIME)
	FROM	[ax].[RETAILTRANSACTIONTABLE] RTT
	WHERE	RTT.DATAAREAID = @nvc_DataAreaId 
			AND RTT.CHANNEL = @bi_ChannelId
			AND RTT.BATCHTERMINALID = @nvc_TerminalId
			AND RTT.BATCHID = @bi_ShiftId
			AND RTT.TYPE = 7 -- 7 for Tender declare operation

	IF (@dtt_StartDateTime IS NULL)
	BEGIN
		SET @dtt_StartDateTime = [crt].GETMINAXDATE();
	END

	-- 2. Retrieves the shift payment transaction summary per tender type
	DECLARE @tvp_ShiftTenderPaymentTransType as [crt].[SHIFTTENDERTRANSTYPE];

	INSERT INTO @tvp_ShiftTenderPaymentTransType
	SELECT	SUM(PTV.TENDEREDAMOUNT) AS TENDEREDAMOUNT,
			PTV.TENDERTYPEID,
			PTV.CURRENCY,
			SUM(PTV.TENDEREDAMOUNTCUR) AS TENDEREDAMOUNTCUR, 
			PTV.CARDTYPEID
	FROM	[crt].[SHIFTTENDERPAYMENTTRANSVIEW] PTV
	WHERE	PTV.COUNTINGREQUIRED = 1 
			AND PTV.CREATEDDATETIME > @dtt_StartDateTime 
			AND PTV.CHANNEL = @bi_ChannelId 
			AND PTV.BATCHTERMINALID = @nvc_TerminalId 
			AND PTV.BATCHID = @bi_ShiftId 
			AND PTV.DATAAREAID = @nvc_DataAreaId 
	GROUP BY PTV.TENDERTYPEID, PTV.CURRENCY, PTV.CARDTYPEID 
	ORDER BY PTV.TENDERTYPEID
	
	-- 3. Retrieves the shift bank drop transaction summary per tender type
	DECLARE @tvp_ShiftTenderBankDropTransType as [crt].[SHIFTTENDERTRANSTYPE];

	INSERT INTO @tvp_ShiftTenderBankDropTransType
	SELECT	SUM(BDTV.TENDEREDAMOUNT) * -1 AS TENDEREDAMOUNT,
			BDTV.TENDERTYPEID,
			BDTV.CURRENCY,
			SUM(BDTV.TENDEREDAMOUNTCUR) * -1 AS TENDEREDAMOUNTCUR, 
			BDTV.CARDTYPEID
	FROM	[crt].[SHIFTTENDERBANKDROPTRANSVIEW] BDTV
	WHERE	BDTV.COUNTINGREQUIRED = 1 
			AND BDTV.CREATEDDATETIME > @dtt_StartDateTime 
			AND BDTV.CHANNEL = @bi_ChannelId 
			AND BDTV.BATCHTERMINALID = @nvc_TerminalId 
			AND BDTV.BATCHID = @bi_ShiftId 
			AND BDTV.DATAAREAID = @nvc_DataAreaId 
	GROUP BY BDTV.TENDERTYPEID, BDTV.CURRENCY, BDTV.CARDTYPEID 
	ORDER BY BDTV.TENDERTYPEID
	
	-- 4. Retrieves the shift safe drop transaction summary per tender type
	DECLARE @tvp_ShiftTenderSafeDropTransType as [crt].[SHIFTTENDERTRANSTYPE];

	INSERT INTO @tvp_ShiftTenderSafeDropTransType
	SELECT	SUM(SDTV.TENDEREDAMOUNT) * -1 AS TENDEREDAMOUNT,
			SDTV.TENDERTYPEID,
			SDTV.CURRENCY,
			SUM(SDTV.TENDEREDAMOUNTCUR) * -1 AS TENDEREDAMOUNTCUR, 
			SDTV.CARDTYPEID
	FROM	[crt].[SHIFTTENDERSAFEDROPTRANSVIEW] SDTV
	WHERE	SDTV.COUNTINGREQUIRED = 1 
			AND SDTV.CREATEDDATETIME > @dtt_StartDateTime 
			AND SDTV.CHANNEL = @bi_ChannelId 
			AND SDTV.BATCHTERMINALID = @nvc_TerminalId 
			AND SDTV.BATCHID = @bi_ShiftId 
			AND SDTV.DATAAREAID = @nvc_DataAreaId 
	GROUP BY SDTV.TENDERTYPEID, SDTV.CURRENCY, SDTV.CARDTYPEID 
	ORDER BY SDTV.TENDERTYPEID

	-- 5. Aggregates the amount grouping by the tender type
	SELECT	SUM(T.TENDEREDAMOUNT) AS TENDEREDAMOUNT,
			T.TENDERTYPEID,
			T.CURRENCY,
			SUM(T.TENDEREDAMOUNTCUR) AS TENDEREDAMOUNTCUR,
			T.CARDTYPEID 
	FROM (
		SELECT	TENDEREDAMOUNT, TENDERTYPEID, CURRENCY, TENDEREDAMOUNTCUR, CARDTYPEID
		FROM	@tvp_ShiftTenderPaymentTransType
		UNION ALL
		SELECT	TENDEREDAMOUNT, TENDERTYPEID, CURRENCY, TENDEREDAMOUNTCUR, CARDTYPEID
		FROM	@tvp_ShiftTenderBankDropTransType
		UNION ALL
		SELECT	TENDEREDAMOUNT, TENDERTYPEID, CURRENCY, TENDEREDAMOUNTCUR, CARDTYPEID
		FROM	@tvp_ShiftTenderSafeDropTransType
	) T
	GROUP BY T.TENDERTYPEID, T.CURRENCY, T.CARDTYPEID
	ORDER BY T.TENDERTYPEID

END;
GO
PRINT N'Refreshing [crt].[GETREFINERSBYTEXT]...';


GO
EXECUTE sp_refreshsqlmodule N'[crt].[GETREFINERSBYTEXT]';


GO
PRINT N'Refreshing [crt].[GETREFINERVALUESBYTEXT]...';


GO
EXECUTE sp_refreshsqlmodule N'[crt].[GETREFINERVALUESBYTEXT]';


GO
/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

-------------------<BEGIN AX SCHEMA ALTERATIONS>--------------------------------------------

-- [ax].[PRICEDISCTABLE]

-- Removing and recreating clustered index, as the original defined in AX cannot be changed
-- and contains 14 columns, causing extreme DB size inflation
IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('ax.PRICEDISCTABLE') AND NAME = 'I_137462222_1904821809')
BEGIN
    ALTER TABLE [ax].[PRICEDISCTABLE]
    DROP CONSTRAINT [I_137462222_1904821809];

    IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('ax.PRICEDISCTABLE') AND NAME = 'I_PRICEDISCTABLE_RECID')
    BEGIN
        ALTER TABLE [ax].[PRICEDISCTABLE]
        DROP CONSTRAINT [I_PRICEDISCTABLE_RECID];
    END;

    ALTER TABLE [ax].[PRICEDISCTABLE]
    ADD CONSTRAINT [I_PRICEDISCTABLE_RECID] PRIMARY KEY CLUSTERED
    (
        [RECID]
    );
END

GO

-- Delete channel report stored procedures
IF OBJECT_ID(N'[crt].[GETBANKDROPREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETBANKDROPREPORT]'
	DROP PROCEDURE [crt].[GETBANKDROPREPORT];
	PRINT 'Dropped [crt].[GETBANKDROPREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETDAYSUMMARY]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETDAYSUMMARY]'
	DROP PROCEDURE [crt].[GETDAYSUMMARY];
	PRINT 'Dropped [crt].[GETDAYSUMMARY]'
END
GO

IF OBJECT_ID(N'[crt].[GETEXPENSETRANSREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETEXPENSETRANSREPORT]'
	DROP PROCEDURE [crt].GETEXPENSETRANSREPORT;
	PRINT 'Dropped [crt].[GETEXPENSETRANSREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETINCOMETRANSREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETINCOMETRANSREPORT]'
	DROP PROCEDURE [crt].GETINCOMETRANSREPORT;
	PRINT 'Dropped [crt].[GETINCOMETRANSREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETOVERSHORTREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETOVERSHORTREPORT]'
	DROP PROCEDURE [crt].GETOVERSHORTREPORT;
	PRINT 'Dropped [crt].[GETOVERSHORTREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETPRODUCTVARIANTSALES]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETPRODUCTVARIANTSALES]'
	DROP PROCEDURE [crt].GETPRODUCTVARIANTSALES;
	PRINT 'Dropped [crt].[GETPRODUCTVARIANTSALES]'
END
GO

IF OBJECT_ID(N'[crt].[GETRETURNTRANSACTIONSREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETRETURNTRANSACTIONSREPORT]'
	DROP PROCEDURE [crt].GETRETURNTRANSACTIONSREPORT;
	PRINT 'Dropped [crt].[GETRETURNTRANSACTIONSREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETSAFEDROPREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETSAFEDROPREPORT]'
	DROP PROCEDURE [crt].GETSAFEDROPREPORT;
	PRINT 'Dropped [crt].[GETSAFEDROPREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETSALESBYDISCOUNTREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETSALESBYDISCOUNTREPORT]'
	DROP PROCEDURE [crt].GETSALESBYDISCOUNTREPORT;
	PRINT 'Dropped [crt].[GETSALESBYDISCOUNTREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETSALESBYHOURREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETSALESBYHOURREPORT]'
	DROP PROCEDURE [crt].GETSALESBYHOURREPORT;
	PRINT 'Dropped [crt].[GETSALESBYHOURREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETSALESBYREGISTERREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETSALESBYREGISTERREPORT]'
	DROP PROCEDURE [crt].GETSALESBYREGISTERREPORT;
	PRINT 'Dropped [crt].[GETSALESBYREGISTERREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETSALESBYSTAFFREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETSALESBYSTAFFREPORT]'
	DROP PROCEDURE [crt].GETSALESBYSTAFFREPORT;
	PRINT 'Dropped [crt].[GETSALESBYSTAFFREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETSALESBYTENDERTYPEREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETSALESBYTENDERTYPEREPORT]'
	DROP PROCEDURE [crt].GETSALESBYTENDERTYPEREPORT;
	PRINT 'Dropped [crt].[GETSALESBYTENDERTYPEREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETSTAFFRETURNSALES]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETSTAFFRETURNSALES]'
	DROP PROCEDURE [crt].GETSTAFFRETURNSALES;
	PRINT 'Dropped [crt].[GETSTAFFRETURNSALES]'
END
GO

IF OBJECT_ID(N'[crt].[GETSTOREPRICEOVERRIDESREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETSTOREPRICEOVERRIDESREPORT]'
	DROP PROCEDURE [crt].GETSTOREPRICEOVERRIDESREPORT;
	PRINT 'Dropped [crt].[GETSTOREPRICEOVERRIDESREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETSTOREVOIDEDTRANSACTIONSREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETSTOREVOIDEDTRANSACTIONSREPORT]'
	DROP PROCEDURE [crt].GETSTOREVOIDEDTRANSACTIONSREPORT;
	PRINT 'Dropped [crt].[GETSTOREVOIDEDTRANSACTIONSREPORT]'
END
GO

IF OBJECT_ID(N'[crt].[GETTOP10PRODUCTSREPORT]', N'P') IS NOT NULL
BEGIN
	PRINT 'Dropping [crt].[GETTOP10PRODUCTSREPORT]'
	DROP PROCEDURE [crt].GETTOP10PRODUCTSREPORT;
	PRINT 'Dropped [crt].[GETTOP10PRODUCTSREPORT]'
END
GO

-- Deleting assortment indexed views
IF OBJECT_ID(N'[crt].[ASSORTEDPRODUCTSINNERVIEW]', N'V') IS NOT NULL
BEGIN
  PRINT 'Dropping [crt].[ASSORTEDPRODUCTSINNERVIEW]'
  DROP VIEW [crt].[ASSORTEDPRODUCTSINNERVIEW];
  PRINT 'Dropped [crt].[ASSORTEDPRODUCTSINNERVIEW]'
END
GO

-- Removing indexes on views to speed up CDX data sync
IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('crt.ITEMCHANNELBASEPRICEVIEW') AND NAME = 'IX_ITEMCHANNELBASEPRICEVIEW')
BEGIN
    PRINT N'Dropping index IX_ITEMCHANNELBASEPRICEVIEW on [crt].ITEMCHANNELBASEPRICEVIEW'
    DROP INDEX IX_ITEMCHANNELBASEPRICEVIEW ON [crt].ITEMCHANNELBASEPRICEVIEW;
END

GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('crt.ITEMCHANNELTRADEAGREEMENTPRICEVIEW') AND NAME = 'IX_ITEMCHANNELTRADEAGREEMENTPRICEVIEW')
BEGIN
    PRINT N'Dropping index IX_ITEMCHANNELTRADEAGREEMENTPRICEVIEW on [crt].ITEMCHANNELTRADEAGREEMENTPRICEVIEW'
    DROP INDEX IX_ITEMCHANNELTRADEAGREEMENTPRICEVIEW ON [crt].ITEMCHANNELTRADEAGREEMENTPRICEVIEW;
END

GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('crt.CHANNELCATEGORYHIERARCHYVIEW') AND NAME = 'IX_CHANNELCATEGORYHIERARCHYVIEW')
BEGIN
    PRINT N'Dropping index IX_CHANNELCATEGORYHIERARCHYVIEW on [crt].CHANNELCATEGORYHIERARCHYVIEW'
    DROP INDEX IX_CHANNELCATEGORYHIERARCHYVIEW ON [crt].CHANNELCATEGORYHIERARCHYVIEW;
END

GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('crt.PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW') AND NAME = 'IX_PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW_CHANNEL_CATALOG')
BEGIN
    PRINT N'Dropping index IX_PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW_CHANNEL_CATALOG on [crt].PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW'
    DROP INDEX IX_PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW_CHANNEL_CATALOG ON [crt].PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW;
END

GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('crt.PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW') AND NAME = 'IX_PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW_CATALOG')
BEGIN
    PRINT N'Dropping index IX_PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW_CATALOG on [crt].PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW'
    DROP INDEX IX_PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW_CATALOG ON [crt].PUBCATALOGCHANNELATTRIBUTEINHERITEDVIEW;
END

GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('crt.PUBCATALOGCHANNELVIEW') AND NAME = 'IX_PUBCATALOGCHANNELVIEW_CHANNEL_CATALOG')
BEGIN
    PRINT N'Dropping index IX_PUBCATALOGCHANNELVIEW_CHANNEL_CATALOG on [crt].PUBCATALOGCHANNELVIEW'
    DROP INDEX IX_PUBCATALOGCHANNELVIEW_CHANNEL_CATALOG ON [crt].PUBCATALOGCHANNELVIEW;
END

GO

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('crt.PUBCATALOGCHANNELVIEW') AND NAME = 'IX_PUBCATALOGCHANNELVIEW_CHANNEL_CATALOG')
BEGIN
    PRINT N'Dropping index IX_PUBCATALOGCHANNELVIEW_CHANNEL_CATALOG on [crt].PUBCATALOGCHANNELVIEW'
    DROP INDEX IX_PUBCATALOGCHANNELVIEW_CHANNEL_CATALOG ON [crt].PUBCATALOGCHANNELVIEW;
END

GO

-- Start deleting triggers on [ax].[CHANNELREFINABLEATTRIBUTE]
IF OBJECT_ID(N'[ax].[CHANNELREFINABLEATTRIBUTE_INSERTED]') IS NOT NULL
BEGIN
  PRINT 'Dropping [ax].[CHANNELREFINABLEATTRIBUTE_INSERTED]'
  DROP TRIGGER [ax].[CHANNELREFINABLEATTRIBUTE_INSERTED];
  PRINT 'Dropped [ax].[CHANNELREFINABLEATTRIBUTE_INSERTED]'    
END
GO

IF OBJECT_ID(N'[ax].[CHANNELREFINABLEATTRIBUTE_UPDATED]') IS NOT NULL
BEGIN
  PRINT 'Dropping [ax].[CHANNELREFINABLEATTRIBUTE_UPDATED]'
  DROP TRIGGER [ax].[CHANNELREFINABLEATTRIBUTE_UPDATED];
  PRINT 'Dropped [ax].[CHANNELREFINABLEATTRIBUTE_UPDATED]'    
END
GO

IF OBJECT_ID(N'[ax].[CHANNELREFINABLEATTRIBUTE_DELETED]') IS NOT NULL
BEGIN
  PRINT 'Dropping [ax].[CHANNELREFINABLEATTRIBUTE_DELETED]'
  DROP TRIGGER [ax].[CHANNELREFINABLEATTRIBUTE_DELETED];
  PRINT 'Dropped [ax].[CHANNELREFINABLEATTRIBUTE_DELETED]'    
END
GO
-- End deleting triggers on [ax].[CHANNELREFINABLEATTRIBUTE]

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('crt.PRODUCTCATALOGRULESVIEW') AND NAME = 'IX_PRODUCTCATALOGRULESVIEW')
BEGIN
    PRINT N'Dropping index IX_PRODUCTCATALOGRULESVIEW on [crt].PRODUCTCATALOGRULESVIEW'
    DROP INDEX IX_PRODUCTCATALOGRULESVIEW ON [crt].PRODUCTCATALOGRULESVIEW;
END

GO

-------------------<END AX SCHEMA ALTERATIONS>--------------------------------------------


