DROP PROGRAM cov_pha_basepkg_update GO
CREATE PROGRAM cov_pha_basepkg_update
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "NDC to Stack (5-4-2)" = ""
	, "Product" = ""
	, "New UOM Package" = 0 

with OUTDEV, NDC, MF_ITEM_ID, PKG_CD
SET cur_mfitem_id = cnvtreal ( $MF_ITEM_ID )
SET cur_uom_cd = cnvtreal ( $PKG_CD )
UPDATE FROM (package_type pt )
  SET pt.uom_cd = cur_uom_cd ,
   pt.updt_id = - (3322 ) ,
   pt.updt_dt_tm = cnvtdatetime (curdate ,curtime3 )
  WHERE (pt.base_package_type_ind = 1 )
  AND (pt.active_ind = 1 )
  AND (pt.item_id = cur_mfitem_id )
  WITH nocounter
;end update
COMMIT
SELECT INTO  $OUTDEV
  mi.item_id ,
  description = mi2.value ,
  ndc = mi.value ,
  pkg_active_ind = p.active_ind ,
  mf_item_id = p.item_id ,
  p.qty ,
  p_uom_disp = uar_get_code_display (p.uom_cd ) ,
  p.uom_cd
  FROM (package_type p ),
   (med_product mp ),
   (med_identifier mi ),
   (med_identifier mi2 )
  PLAN (p
   WHERE (p.active_ind = 1 )
   AND (p.base_package_type_ind = 1 )
   AND (p.item_id = cur_mfitem_id ) )
   JOIN (mp
   WHERE (mp.manf_item_id = p.item_id ) )
   JOIN (mi
   WHERE (mi.med_product_id = mp.med_product_id )
   AND (mi.active_ind = 1 )
   AND (mi.med_identifier_type_cd = value (uar_get_code_by ("MEANING" ,11000 ,"NDC" ) ) ) )
   JOIN (mi2
   WHERE (mi2.item_id = mi.item_id )
   AND (mi2.active_ind = 1 )
   AND (mi2.primary_ind = 1 )
   AND (mi2.med_product_id = 0 )
   AND (mi2.med_identifier_type_cd = value (uar_get_code_by ("MEANING" ,11000 ,"DESC" ) ) )
   AND (mi2.pharmacy_type_cd = value (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT" ) ) ) )
  ORDER BY mi2.value
  WITH nocounter ,separator = " " ,format
;end select
;#end
END GO
