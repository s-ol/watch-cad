=>
  input.selection @to_delete
  for b in *@to_delete!
    op.remove b
