free record request go
record request (
	1 batch_selection = vc
	1 output_dist = vc
	1 ops_date = dq8
	) go
 
Free record reply go
record reply (
	1 ops_event = vc
%i cclsource:status_block.inc
	) go
 
execute
	COV_MEDREB8_EXTRACT
 
	"MINE"
	, 0
	, "01-MAR-2022 00:00:00"
	, "31-MAR-2022 23:59:59"
	, VALUE(2552503635.00, 21250403.00, 2552503653.00, 2552503613.00, 2552503639.00, 2552503645.00, 2552503649.00, 2553765579.00)
go
