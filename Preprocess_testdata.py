import wfdb
import numpy as np

record = wfdb.rdrecord('100', sampto=5000)
raw_signal = record.p_signal[:, 0]  # Focus on the MLII lead

#Scale to 12-bit integer range (-2048 to 2047)
signal_min = np.min(raw_signal)
signal_max = np.max(raw_signal)

normalized = 2 * (raw_signal - signal_min) / (signal_max - signal_min) - 1
adc_data = (normalized * 2047).astype(np.int16)

# Write to .hex file for $readmemh
with open('ecg_raw_data.hex', 'w') as f:
    for value in adc_data:
 
        f.write(f"{value & 0xFFF:03x}\n")

print(f"Exported {len(adc_data)} samples to ecg_raw_data.hex")