pet: petnetwork

# make the Yeo rois from montez's PC motion regressed brains
DM_motion:
	./maskavg_dm.bash

petraw:
	./all_pet_test_retest.bash
petpreproc: petraw
	./runall_pet.bash
petnetwork: petpreproc
	./maskavg_retest.bash
