pub struct RingBuffer {
    pub inner: Box<[i16]>,

    pub write_pos: usize,
    pub read_pos: usize,

    pub samples_written: u64,
    pub samples_read: u64,
}

impl RingBuffer {
    pub fn push(&mut self, value: i16) {
        self.inner[self.write_pos] = value;

        self.write_pos += 1;
        if self.write_pos >= self.inner.len() {
            self.write_pos = 0;
        }

        self.samples_written += 1;
    }
}

impl Iterator for RingBuffer {
    type Item = i16;

    fn next(&mut self) -> Option<i16> {
        let ret = self.inner[self.read_pos];

        self.read_pos += 1;
        if self.read_pos >= self.inner.len() {
            self.read_pos = 0;
        }

        self.samples_read += 1;

        Some(ret)
    }
}
