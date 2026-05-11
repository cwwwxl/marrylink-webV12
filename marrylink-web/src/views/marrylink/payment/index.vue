<template>
  <div class="app-container">
    <div class="search-container">
      <el-form :model="queryParams" :inline="true">
        <el-form-item label="订单号">
          <el-input
            v-model="queryParams.orderNo"
            placeholder="订单号"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>

        <el-form-item label="托管状态" style="width: 150px;">
          <el-select v-model="queryParams.status" placeholder="全部" clearable>
            <el-option label="托管中" :value="1" />
            <el-option label="已结算" :value="2" />
            <el-option label="已退款" :value="3" />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" icon="search" @click="handleQuery">搜索</el-button>
          <el-button icon="refresh" @click="handleResetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-card shadow="hover">
      <el-table v-loading="loading" :data="pageData" border stripe>
        <el-table-column label="ID" prop="id" width="80" />
        <el-table-column label="订单号" prop="orderNo" width="180" />
        <el-table-column label="托管金额（定金）" width="150">
          <template #default="scope">
            ¥{{ Number(scope.row.amount).toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="订单总金额" width="130">
          <template #default="scope">
            ¥{{ Number(scope.row.totalOrderAmount).toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="托管状态" width="100">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="支付时间" prop="payTime" width="170" />
        <el-table-column label="结算时间" prop="settleTime" width="170" />
        <el-table-column label="创建时间" prop="createTime" width="170" />
        <el-table-column label="操作" fixed="right" width="100">
          <template #default="scope">
            <el-button type="primary" icon="view" link size="small" @click="handleView(scope.row)">
              查看
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <pagination
        v-if="total > 0"
        v-model:total="total"
        v-model:page="queryParams.current"
        v-model:limit="queryParams.size"
        @pagination="fetchData"
      />
    </el-card>

    <!-- 详情弹窗 -->
    <el-dialog v-model="dialog.visible" :title="dialog.title" width="600px">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="ID">{{ detail.id }}</el-descriptions-item>
        <el-descriptions-item label="订单号">{{ detail.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="托管金额（定金）">¥{{ Number(detail.amount).toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item label="订单总金额">¥{{ Number(detail.totalOrderAmount).toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item label="托管状态">
          <el-tag :type="getStatusType(detail.status)">
            {{ getStatusText(detail.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="支付时间">{{ detail.payTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="结算时间">{{ detail.settleTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ detail.createTime }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="dialog.visible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import Pagination from '@/components/Pagination/index.vue'
import { getEscrowPage } from '@/api/marrylink-api'

const queryParams = reactive({
  current: 1,
  size: 10,
  orderNo: '',
  status: null
})

const pageData = ref([])
const total = ref(0)
const loading = ref(false)

const dialog = reactive({
  visible: false,
  title: '托管详情'
})

const detail = reactive({
  id: '',
  orderNo: '',
  amount: 0,
  totalOrderAmount: 0,
  status: null,
  payTime: '',
  settleTime: '',
  createTime: ''
})

function getStatusType(status) {
  const types = { 1: 'warning', 2: 'success', 3: 'danger' }
  return types[status] || 'info'
}

function getStatusText(status) {
  const texts = { 1: '托管中', 2: '已结算', 3: '已退款' }
  return texts[status] || '未知'
}

async function fetchData() {
  loading.value = true
  try {
    const res = await getEscrowPage(queryParams)
    pageData.value = res.records
    total.value = res.total
  } finally {
    loading.value = false
  }
}

function handleQuery() {
  queryParams.current = 1
  fetchData()
}

function handleResetQuery() {
  queryParams.orderNo = ''
  queryParams.status = null
  handleQuery()
}

function handleView(row) {
  Object.assign(detail, row)
  dialog.title = '托管详情'
  dialog.visible = true
}

onMounted(() => {
  fetchData()
})
</script>
