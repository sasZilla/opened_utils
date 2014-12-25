gradeHumanize = (grade) ->
  return grade if grade == 'k' or grade == 'K' 
  return grade + 'th' if parseInt(grade) > 3 and parseInt(grade) <= 12
  return grade + 'st' if parseInt(grade) == 1
  return grade + 'nd' if parseInt(grade) == 2
  return grade + 'rd' if parseInt(grade) == 3
  return false

`export default gradeHumanize`
