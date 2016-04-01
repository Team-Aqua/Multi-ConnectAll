## 
# DESIGN DECISION:
# There is no view_contracts, nor any contract for any other views. This is intentional, 
# as issues are either captured by the controller or the Gosu framework. For example,
# issues such as misisng file assets are caught by Gosu, and improper model values 
# are captured by the controller. As a result, we do not have to write any contracts
# except for the actual data being passed - which will be handled by contracts.rb, and does not
# have to be written specifically for this project.
##