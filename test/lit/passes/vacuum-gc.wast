;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --vacuum -all -S -o - | filecheck %s

(module
  (type ${} (struct))

  ;; CHECK:      (func $drop-ref-as (param $x anyref)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (ref.as_non_null
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (ref.as_func
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (ref.as_data
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (ref.as_i31
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $drop-ref-as (param $x anyref)
    ;; Without -tnh, we must assume all ref_as* can have a trap effect, and so
    ;; we cannot remove anything here.
    (drop
      (ref.as_non_null
        (local.get $x)
      )
    )
    (drop
      (ref.as_func
        (local.get $x)
      )
    )
    (drop
      (ref.as_data
        (local.get $x)
      )
    )
    (drop
      (ref.as_i31
        (local.get $x)
      )
    )
  )

  ;; CHECK:      (func $vacuum-rtt-with-depth
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $vacuum-rtt-with-depth
    (drop
      (if (result (rtt 1 ${}))
        (i32.const 1)
        ;; This block's result is not used. As a consequence vacuum will try to
        ;; generate a replacement zero for the block's fallthrough value. An rtt
        ;; with depth is a problem for that, since we can't just create an
        ;; rtt.canon - we'd need to add some rtt.subs, and it's not clear that we'd
        ;; be improving code size while doing so, hence we do not allow making a
        ;; zero of that type. Vacuum should not error on trying to do so. And
        ;; the end result of this function should simply be empty, as everything
        ;; here can be vacuumed away.
        (block (result (rtt 1 ${}))
          (rtt.sub ${}
            (rtt.canon ${})
          )
        )
        (unreachable)
      )
    )
  )

  ;; CHECK:      (func $drop-i31.get (param $ref (ref null i31)) (param $ref-nn i31ref)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i31.get_s
  ;; CHECK-NEXT:    (local.get $ref)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $drop-i31.get (param $ref (ref null i31)) (param $ref-nn (ref i31))
    ;; A nullable get might trap, so only the second item can be removed.
    (drop
      (i31.get_s
        (local.get $ref)
      )
    )
    (drop
      (i31.get_s
        (local.get $ref-nn)
      )
    )
  )
)
