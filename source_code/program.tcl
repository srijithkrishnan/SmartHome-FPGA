open_hw_manager                              
connect_hw_server                            
open_hw_target                               
current_hw_device                            
set_property PROGRAM.FILE {smart_wrapper.bit} [current_hw_device]
program_hw_device 
close_hw_manager