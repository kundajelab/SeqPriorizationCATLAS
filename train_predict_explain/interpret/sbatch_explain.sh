#!/bin/bash

models=/oak/stanford/groups/akundaje/projects/aav/svm_training
indir=/oak/stanford/groups/akundaje/projects/aav/explain_inputs
outdir=/oak/stanford/groups/akundaje/projects/aav/explain_scores
explain_script=***Insert path to run_explain_hyp.sh script***
lsgkm_dir=***Insert path to lsgkm***

[[ -d $outdir/logs ]] || mkdir $outdir/logs

for cluster in D2MSN  
do
    echo $cluster

    [[ -d $outdir/$cluster ]] || mkdir $outdir/$cluster
    [[ -d $outdir/logs/$cluster ]] || mkdir $outdir/logs/$cluster

    for fold in `seq 0 0`
    do
        echo Fold $fold

        [[ -d $outdir/$cluster/fold$fold ]] || mkdir $outdir/$cluster/fold$fold
        [[ -d $outdir/logs/$cluster/fold$fold ]] || mkdir $outdir/logs/$cluster/fold$fold
        [[ -d $outdir/$cluster/fold$fold/split_scores ]] || mkdir $outdir/$cluster/fold$fold/split_scores

        for split in `ls $indir/split_inputs/*.fasta-*`
        do
            num=${split: -3}
            if [ $num -gt 449 ]
            then
                [[ -f $outdir/$cluster/fold$fold/split_scores/$cluster.fold$fold.explain-${split:(-3)} ]] ||
                echo $outdir/$cluster/fold$fold/split_scores/$cluster.fold$fold.explain-${split:(-3)}

                [[ -f $outdir/$cluster/fold$fold/split_scores/$cluster.fold$fold.explain-${split:(-3)} ]] ||
                sbatch --export=ALL \
                       --mem=10000 \
                       --requeue \
                       -t 1440 \
                       -p akundaje,owners,normal \
                       -J $cluster.$fold-${split:(-3)} \
                       -o $outdir/logs/$cluster/fold$fold/$cluster.fold$fold-${split:(-3)}.o \
                       -e $outdir/logs/$cluster/fold$fold/$cluster.fold$fold-${split:(-3)}.e \
                       $explain_script $models/$cluster/models/${cluster}.$fold.model.txt $split $outdir/$cluster/fold$fold/split_scores/$cluster.fold$fold.explain-${split:(-3)} $lsgkm_dir
            fi
        done
    done
done
