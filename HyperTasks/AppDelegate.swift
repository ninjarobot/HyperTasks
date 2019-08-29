//
//  AppDelegate.swift
//  HyperTasks
//
//  Created by David Curylo on 8/28/19.
//  Copyright © 2019 Dave Curylo. All rights reserved.
//

import Cocoa
import Hypervisor

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBAction func launchVM(_ sender: Any) {
        let vmSizeBytes = 1024 * 1024 * 1024 * 2
        let t = hv_vm_create(hv_vm_options_t(HV_VM_DEFAULT));
        switch (Int(t)) {
        case HV_SUCCESS:
            print("Created VM")
            let mem = valloc(vmSizeBytes) // 2 GiB memory
            if (hv_vm_map(mem, 0, vmSizeBytes, hv_memory_flags_t(HV_MEMORY_READ | HV_MEMORY_WRITE | HV_MEMORY_EXEC)) == HV_SUCCESS) {
                print("Mapped memory")
                let cpu : UnsafeMutablePointer<hv_vcpuid_t> = UnsafeMutablePointer.allocate(capacity: 1)
                if(hv_vcpu_create(cpu, hv_vcpu_options_t(HV_VCPU_DEFAULT)) == HV_SUCCESS) {
                    print("Created vCPU")
                    hv_vcpu_destroy(cpu.pointee)
                    print("Destroyed vCPU")
                    cpu.deallocate()
                    print("Deallocated pointer to cpu")
                    hv_vm_unmap(0, vmSizeBytes)
                    print("Unmapped memory")
                    hv_vm_destroy()
                    print("Destroyed VM")
                    free(mem)
                    print("Freed memory")
                }
            }
        case HV_ERROR:
            print("Error creating VM");
        default:
            print("Some other case \(t)")
    }
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

