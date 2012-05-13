#%%  This is a TeX comment

require 'legal'
require 'ded'

# Case information
$cs = Case.new('06 Civil 6097')
$cs.court = Court.new('United States District Court for the Southern District of New York')
$cs.court.address = Address.new('40 Centre Street', '', 'New York','NY', '10007--1581')
$cs.court.division = 'Centre Street'
$cs.court.judge = Person.new('male', 'Scalia', 'Antonine')
$cs.court.judge.initials = 'AS'

# Plaintiffs lawyers
$ded.bar_number = 'DD--2145'
$lopez = Lawyer.new('male', 'Lopez', 'David', '')
$lopez.address = Address.new('171 Edge of Woods Road', '',
'Southampton', 'NY', '11969--0323')
$lopez.phone = '631-287-5520'
$lopez.fax = '631-283-4735'
$lopez.email = 'davidlopezesq@aol.com'
$lopez.bar_number = 'DL--6799'
$lopez.bar_state = 'New York'
$lopez.email = 'DavidLopezEsq@aol.com'

# Defense Officers
$hidalgo = Lawyer.new('male', 'Hidalgo', 'Andrew', '')
$hidalgo.address = Address.new('WPCS International', '140 South Village Ave.,
Suite 20', 'Exton', 'PA', '19341')

$marxe1 = Lawyer.new('male', 'Marxe', 'Austin', '')
$marxe1.address = Address.new('Special Situations Fund III, QP, LP',
 '153 East 53rd Street', 'New York', 'NY', '10022')

$marxe2 = Lawyer.new('male', 'Marxe', 'Austin', '')
$marxe2.address = Address.new('Special Situations Private Equity Fund, LP',
 '153 East 53rd Street', 'New York', 'NY', '10022')

# Plaintiff
huppe = Party.new('female', 'Huppe', 'Maureen', 'A.')
huppe.role = 'Plaintiff'
huppe.add_lawyer($lopez)
huppe.add_lawyer($ded)

# Defendants
wpcs = Party.new('entity', 'WPCS International Incorporated')
wpcs.role = 'Defendant'
qp = Party.new('entity', 'Special Situations Fund QP, L.P.')
qp.role = 'Defendant'
pe = Party.new('entity',
  'Special Situations Private Equity Fund, L.P.')
pe.role = 'Defendant'

# Defense Lawyers (Update after Answer)
wpcs.add_lawyer($hidalgo)
qp.add_lawyer($marxe1)
pe.add_lawyer($marxe2)

# Add parties to case
$cs.add_plaintiff(huppe)
$cs.add_defendant(wpcs)
$cs.add_defendant(qp)
$cs.add_defendant(pe)

